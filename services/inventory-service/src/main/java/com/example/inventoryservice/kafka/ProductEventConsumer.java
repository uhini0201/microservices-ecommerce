package com.example.inventoryservice.kafka;

import com.example.inventoryservice.service.InventoryService;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class ProductEventConsumer {

    private final InventoryService inventoryService;

    public ProductEventConsumer(InventoryService inventoryService) {
        this.inventoryService = inventoryService;
    }

    @KafkaListener(topics = "product-created", groupId = "inventory-service-group")
    public void handleProductCreated(Map<String, Object> event) {
        try {
            Long productId = getLongValue(event.get("id"));
            String productName = (String) event.get("name");
            Integer stock = getIntegerValue(event.get("stock"));

            if (productId != null && productName != null && stock != null) {
                inventoryService.initializeInventory(productId, productName, stock);
                System.out.println("Inventory initialized for product: " + productId + " - " + productName);
            }
        } catch (Exception e) {
            System.err.println("Error processing product-created event: " + e.getMessage());
        }
    }

    @KafkaListener(topics = "product-updated", groupId = "inventory-service-group")
    public void handleProductUpdated(Map<String, Object> event) {
        try {
            Long productId = getLongValue(event.get("id"));
            String productName = (String) event.get("name");
            Integer stock = getIntegerValue(event.get("stock"));

            if (productId != null && productName != null && stock != null) {
                inventoryService.updateInventory(productId, productName, stock);
                System.out.println("Inventory updated for product: " + productId);
            }
        } catch (Exception e) {
            System.err.println("Error processing product-updated event: " + e.getMessage());
        }
    }

    @KafkaListener(topics = "product-deleted", groupId = "inventory-service-group")
    public void handleProductDeleted(Map<String, Object> event) {
        try {
            Long productId = getLongValue(event.get("id"));
            
            if (productId != null) {
                inventoryService.deleteInventory(productId);
                System.out.println("Inventory deleted for product: " + productId);
            }
        } catch (Exception e) {
            System.err.println("Error processing product-deleted event: " + e.getMessage());
        }
    }

    private Long getLongValue(Object value) {
        if (value == null) return null;
        if (value instanceof Long) return (Long) value;
        if (value instanceof Integer) return ((Integer) value).longValue();
        if (value instanceof String) return Long.parseLong((String) value);
        return null;
    }

    private Integer getIntegerValue(Object value) {
        if (value == null) return null;
        if (value instanceof Integer) return (Integer) value;
        if (value instanceof Long) return ((Long) value).intValue();
        if (value instanceof String) return Integer.parseInt((String) value);
        return null;
    }
}
