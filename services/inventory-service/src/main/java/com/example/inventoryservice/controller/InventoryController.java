package com.example.inventoryservice.controller;

import com.example.inventoryservice.dto.ReserveStockRequest;
import com.example.inventoryservice.exception.InsufficientStockException;
import com.example.inventoryservice.exception.InventoryNotFoundException;
import com.example.inventoryservice.model.Inventory;
import com.example.inventoryservice.service.InventoryService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/inventory")
@Validated
public class InventoryController {

    private final InventoryService inventoryService;

    public InventoryController(InventoryService inventoryService) {
        this.inventoryService = inventoryService;
    }

    @GetMapping("/{productId}")
    public ResponseEntity<Inventory> getInventory(@PathVariable Long productId) {
        Inventory inventory = inventoryService.getInventoryByProductId(productId);
        return ResponseEntity.ok(inventory);
    }

    @GetMapping
    public ResponseEntity<List<Inventory>> getAllInventory() {
        List<Inventory> inventory = inventoryService.getAllInventory();
        return ResponseEntity.ok(inventory);
    }

    @GetMapping("/low-stock")
    public ResponseEntity<List<Inventory>> getLowStock() {
        List<Inventory> lowStock = inventoryService.getLowStockItems();
        return ResponseEntity.ok(lowStock);
    }

    @PostMapping("/reserve")
    public ResponseEntity<Inventory> reserveStock(@Valid @RequestBody ReserveStockRequest request) {
        Inventory inventory = inventoryService.reserveStock(request.getProductId(), request.getQuantity());
        return ResponseEntity.ok(inventory);
    }

    @PostMapping("/release")
    public ResponseEntity<Inventory> releaseStock(@Valid @RequestBody ReserveStockRequest request) {
        Inventory inventory = inventoryService.releaseStock(request.getProductId(), request.getQuantity());
        return ResponseEntity.ok(inventory);
    }

    @PostMapping("/confirm")
    public ResponseEntity<Inventory> confirmReservation(@Valid @RequestBody ReserveStockRequest request) {
        Inventory inventory = inventoryService.confirmReservation(request.getProductId(), request.getQuantity());
        return ResponseEntity.ok(inventory);
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Inventory service is running");
    }

    @ExceptionHandler(InventoryNotFoundException.class)
    public ResponseEntity<Map<String, String>> handleInventoryNotFound(InventoryNotFoundException ex) {
        Map<String, String> error = new HashMap<>();
        error.put("error", "Inventory Not Found");
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
}
