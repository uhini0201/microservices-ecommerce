package com.example.apigateway.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/fallback")
public class FallbackController {

    @GetMapping("/auth")
    public ResponseEntity<Map<String, String>> authFallback() {
        Map<String, String> response = new HashMap<>();
        response.put("error", "Authentication service is currently unavailable");
        response.put("message", "Please try again later");
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(response);
    }

    @GetMapping("/user")
    public ResponseEntity<Map<String, String>> userFallback() {
        Map<String, String> response = new HashMap<>();
        response.put("error", "User service is currently unavailable");
        response.put("message", "Please try again later");
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(response);
    }

    @GetMapping("/product")
    public ResponseEntity<Map<String, String>> productFallback() {
        Map<String, String> response = new HashMap<>();
        response.put("error", "Product service is currently unavailable");
        response.put("message", "Please try again later");
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(response);
    }

    @GetMapping("/order")
    public ResponseEntity<Map<String, String>> orderFallback() {
        Map<String, String> response = new HashMap<>();
        response.put("error", "Order service is currently unavailable");
        response.put("message", "Please try again later");
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(response);
    }

    @GetMapping("/inventory")
    public ResponseEntity<Map<String, String>> inventoryFallback() {
        Map<String, String> response = new HashMap<>();
        response.put("error", "Inventory service is currently unavailable");
        response.put("message", "Please try again later");
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(response);
    }

    @GetMapping("/notification")
    public ResponseEntity<Map<String, String>> notificationFallback() {
        Map<String, String> response = new HashMap<>();
        response.put("error", "Notification service is currently unavailable");
        response.put("message", "Please try again later");
        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(response);
    }
}
