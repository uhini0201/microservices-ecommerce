package com.example.orderservice.config;

import org.springframework.http.HttpRequest;
import org.springframework.http.client.ClientHttpRequestExecution;
import org.springframework.http.client.ClientHttpRequestInterceptor;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;

/**
 * Interceptor that forwards the JWT Authorization header from incoming requests
 * to outgoing RestTemplate requests.
 */
public class JwtForwardingInterceptor implements ClientHttpRequestInterceptor {

    @Override
    public ClientHttpResponse intercept(HttpRequest request, byte[] body, ClientHttpRequestExecution execution) 
            throws IOException {
        
        // Try to get the Authorization header from the current HTTP request
        try {
            ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attributes != null) {
                HttpServletRequest currentRequest = attributes.getRequest();
                String authHeader = currentRequest.getHeader("Authorization");
                
                if (authHeader != null && authHeader.startsWith("Bearer ")) {
                    // Forward the Authorization header to the outgoing request
                    request.getHeaders().set("Authorization", authHeader);
                    System.out.println("JWT Forwarding: Added Authorization header to outgoing request");
                } else {
                    System.out.println("JWT Forwarding: No Authorization header found in current request");
                }
            } else {
                System.out.println("JWT Forwarding: RequestContextHolder has no attributes");
            }
        } catch (Exception e) {
            System.out.println("JWT Forwarding: Error getting request attributes: " + e.getMessage());
        }
        
        return execution.execute(request, body);
    }
}
