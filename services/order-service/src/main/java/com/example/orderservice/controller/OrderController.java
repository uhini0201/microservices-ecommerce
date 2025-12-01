package com.example.orderservice.controller;

import com.example.orderservice.dto.OrderRequest;
import com.example.orderservice.exception.InsufficientStockException;
import com.example.orderservice.exception.ProductNotFoundException;
import com.example.orderservice.exception.ProductServiceUnavailableException;
import com.example.orderservice.model.Order;
import com.example.orderservice.service.OrderService;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/orders")
@Validated
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @PostMapping
    public ResponseEntity<Order> createOrder(@Valid @RequestBody OrderRequest req) {
        Order order = orderService.createOrder(req);
        return ResponseEntity.status(201).body(order);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrder(@PathVariable Long id) {
        Order order = orderService.getOrder(id);
        if (order == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(order);
    }

    @ExceptionHandler(ProductNotFoundException.class)
    public ResponseEntity<Map<String, String>> handleProductNotFound(ProductNotFoundException ex) {
        Map<String, String> error = new HashMap<>();
        error.put("error", "Product Not Found");
        error.put("message", ex.getMessage());
        return ResponseEntity.status(404).body(error);
    }

    @ExceptionHandler(InsufficientStockException.class)
    public ResponseEntity<Map<String, String>> handleInsufficientStock(InsufficientStockException ex) {
        Map<String, String> error = new HashMap<>();
        error.put("error", "Insufficient Stock");
        error.put("message", ex.getMessage());
        return ResponseEntity.status(400).body(error);
    }

    @ExceptionHandler(ProductServiceUnavailableException.class)
    public ResponseEntity<Map<String, String>> handleProductServiceUnavailable(ProductServiceUnavailableException ex) {
        Map<String, String> error = new HashMap<>();
        error.put("error", "Service Unavailable");
        error.put("message", ex.getMessage());
        return ResponseEntity.status(503).body(error);
    }
}
