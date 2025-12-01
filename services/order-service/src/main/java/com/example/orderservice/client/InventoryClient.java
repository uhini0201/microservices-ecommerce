package com.example.orderservice.client;

import com.example.orderservice.exception.InsufficientStockException;
import com.example.orderservice.exception.InventoryServiceException;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
public class InventoryClient {
    private static final Logger logger = LoggerFactory.getLogger(InventoryClient.class);

    private final RestTemplate restTemplate;
    private final String inventoryServiceUrl;

    public InventoryClient(RestTemplate restTemplate,
                          @Value("${inventory-service.url}") String inventoryServiceUrl) {
        this.restTemplate = restTemplate;
        this.inventoryServiceUrl = inventoryServiceUrl;
    }

    @CircuitBreaker(name = "inventoryService", fallbackMethod = "reserveStockFallback")
    public void reserveStock(Long productId, Integer quantity) {
        try {
            String url = inventoryServiceUrl + "/inventory/reserve";
            
            Map<String, Object> request = new HashMap<>();
            request.put("productId", productId);
            request.put("quantity", quantity);
            
            logger.info("Reserving {} units of product {} at {}", quantity, productId, url);
            restTemplate.postForObject(url, request, Map.class);
            logger.info("Successfully reserved {} units of product {}", quantity, productId);
            
        } catch (HttpClientErrorException e) {
            logger.error("Error reserving stock for product {}: {}", productId, e.getMessage());
            
            if (e.getStatusCode() == HttpStatus.BAD_REQUEST) {
                // Throw a generic InventoryServiceException since we don't have stock details from inventory-service
                throw new InventoryServiceException("Insufficient stock available for product " + productId);
            } else if (e.getStatusCode() == HttpStatus.NOT_FOUND) {
                throw new InventoryServiceException("Product not found in inventory: " + productId);
            }
            
            throw new InventoryServiceException("Failed to reserve stock: " + e.getMessage());
        } catch (Exception e) {
            logger.error("Unexpected error reserving stock: {}", e.getMessage());
            throw new InventoryServiceException("Inventory service unavailable: " + e.getMessage());
        }
    }

    @CircuitBreaker(name = "inventoryService", fallbackMethod = "releaseStockFallback")
    public void releaseStock(Long productId, Integer quantity) {
        try {
            String url = inventoryServiceUrl + "/inventory/release";
            
            Map<String, Object> request = new HashMap<>();
            request.put("productId", productId);
            request.put("quantity", quantity);
            
            logger.info("Releasing {} units of product {}", quantity, productId);
            restTemplate.postForObject(url, request, Map.class);
            logger.info("Successfully released {} units of product {}", quantity, productId);
            
        } catch (Exception e) {
            logger.error("Error releasing stock: {}", e.getMessage());
            // Don't throw exception - releasing stock is a compensating transaction
            // Log the error but continue
        }
    }

    // Fallback method for circuit breaker
    private void reserveStockFallback(Long productId, Integer quantity, Throwable throwable) {
        logger.error("Circuit breaker activated for reserveStock - productId: {}, error: {}", 
                    productId, throwable.getMessage());
        throw new InventoryServiceException("Inventory service is currently unavailable. Please try again later.");
    }

    // Fallback method for circuit breaker
    private void releaseStockFallback(Long productId, Integer quantity, Throwable throwable) {
        logger.error("Circuit breaker activated for releaseStock - productId: {}, error: {}", 
                    productId, throwable.getMessage());
        // Don't throw - just log the failure
    }
}
