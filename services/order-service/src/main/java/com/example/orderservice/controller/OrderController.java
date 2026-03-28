package com.example.orderservice.controller;

import com.example.orderservice.dto.InvoiceResponse;
import com.example.orderservice.dto.OrderRequest;
import com.example.orderservice.dto.OrderResponse;
import com.example.orderservice.exception.InsufficientStockException;
import com.example.orderservice.exception.ProductNotFoundException;
import com.example.orderservice.exception.ProductServiceUnavailableException;
import com.example.orderservice.model.Order;
import com.example.orderservice.service.OrderService;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.security.Principal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/orders")
@Validated
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @PostMapping
    public ResponseEntity<OrderResponse> createOrder(@Valid @RequestBody OrderRequest req) {
        Order order = orderService.createOrder(req);
        OrderResponse response = new OrderResponse(order);
        return ResponseEntity.status(201).body(response);
    }

    @GetMapping
    public ResponseEntity<List<OrderResponse>> getAllOrders(Principal principal) {
        String username = principal.getName();
        List<Order> orders = orderService.getOrdersByCustomer(username);
        List<OrderResponse> responses = orders.stream()
                .map(OrderResponse::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/{id}")
    public ResponseEntity<OrderResponse> getOrder(@PathVariable Long id) {
        Order order = orderService.getOrder(id);
        if (order == null) {
            return ResponseEntity.notFound().build();
        }
        OrderResponse response = new OrderResponse(order);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}/invoice")
    public ResponseEntity<InvoiceResponse> getInvoice(@PathVariable Long id) {
        Order order = orderService.getOrder(id);
        if (order == null) {
            return ResponseEntity.notFound().build();
        }
        InvoiceResponse invoice = new InvoiceResponse(order);
        return ResponseEntity.ok(invoice);
    }

    @PutMapping("/{id}/cancel")
    public ResponseEntity<OrderResponse> cancelOrder(@PathVariable Long id, Principal principal) {
        String username = principal.getName();
        try {
            Order order = orderService.cancelOrder(id, username);
            OrderResponse response = new OrderResponse(order);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Not Found");
            error.put("message", e.getMessage());
            return ResponseEntity.status(404).body(null);
        } catch (IllegalStateException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Bad Request");
            error.put("message", e.getMessage());
            return ResponseEntity.status(400).body(null);
        }
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
