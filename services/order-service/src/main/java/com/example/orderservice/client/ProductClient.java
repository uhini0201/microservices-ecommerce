package com.example.orderservice.client;

import com.example.orderservice.dto.ProductDTO;
import com.example.orderservice.exception.ProductNotFoundException;
import com.example.orderservice.exception.ProductServiceUnavailableException;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestTemplate;

@Service
public class ProductClient {

    private final RestTemplate restTemplate;

    @Value("${product-service.url}")
    private String productServiceUrl;

    public ProductClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @CircuitBreaker(name = "productService", fallbackMethod = "getProductFallback")
    public ProductDTO getProduct(Long productId) {
        try {
            String url = productServiceUrl + "/products/" + productId;
            ProductDTO product = restTemplate.getForObject(url, ProductDTO.class);
            
            if (product == null) {
                throw new ProductNotFoundException(productId);
            }
            
            return product;
        } catch (HttpClientErrorException.NotFound e) {
            throw new ProductNotFoundException(productId);
        } catch (ResourceAccessException e) {
            throw new ProductServiceUnavailableException("Product service is unavailable", e);
        } catch (Exception e) {
            throw new ProductServiceUnavailableException("Error communicating with product service: " + e.getMessage(), e);
        }
    }

    private ProductDTO getProductFallback(Long productId, Throwable throwable) {
        throw new ProductServiceUnavailableException("Product service is currently unavailable. Circuit breaker is open. Please try again later.");
    }
}
