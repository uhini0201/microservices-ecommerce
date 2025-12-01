package com.example.apigateway.security;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.List;

@Component
public class JwtAuthenticationFilter implements GlobalFilter, Ordered {

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    @Autowired
    private JwtUtils jwtUtils;

    // Public endpoints that don't require authentication
    private static final List<String> PUBLIC_ENDPOINTS = List.of(
            "/api/auth/register",
            "/api/auth/login",
            "/api/auth/refresh",
            "/api/auth/logout",
            "/api/products/health",
            "/api/orders/health",
            "/api/inventory/health",
            "/api/notifications/health",
            "/api/users/health",
            "/api/auth/health",
            "/actuator/health",
            "/fallback"
    );

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        String path = request.getURI().getPath();

        logger.debug("Request path: {}", path);

        // Skip JWT validation for public endpoints
        if (isPublicEndpoint(path)) {
            logger.debug("Public endpoint, skipping JWT validation: {}", path);
            return chain.filter(exchange);
        }

        // Extract JWT token
        String jwt = parseJwt(request);

        if (jwt == null || !jwtUtils.validateJwtToken(jwt)) {
            logger.error("Invalid or missing JWT token for path: {}", path);
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        // Extract username and add to request header for downstream services
        String username = jwtUtils.getUsernameFromJwtToken(jwt);
        logger.debug("Validated JWT for user: {}", username);

        // Add username and preserve Authorization header for downstream services
        ServerHttpRequest modifiedRequest = exchange.getRequest().mutate()
                .header("X-Auth-Username", username)
                .header("Authorization", "Bearer " + jwt)
                .build();

        return chain.filter(exchange.mutate().request(modifiedRequest).build());
    }

    private boolean isPublicEndpoint(String path) {
        return PUBLIC_ENDPOINTS.stream().anyMatch(path::startsWith);
    }

    private String parseJwt(ServerHttpRequest request) {
        String headerAuth = request.getHeaders().getFirst(HttpHeaders.AUTHORIZATION);

        if (StringUtils.hasText(headerAuth) && headerAuth.startsWith("Bearer ")) {
            return headerAuth.substring(7);
        }

        return null;
    }

    @Override
    public int getOrder() {
        return -1; // Execute before other filters
    }
}
