package com.example.inventoryservice.service;

import com.example.inventoryservice.exception.InsufficientStockException;
import com.example.inventoryservice.exception.InventoryNotFoundException;
import com.example.inventoryservice.model.Inventory;
import com.example.inventoryservice.repository.InventoryRepository;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class InventoryService {

    private final InventoryRepository inventoryRepository;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    public InventoryService(InventoryRepository inventoryRepository, KafkaTemplate<String, Object> kafkaTemplate) {
        this.inventoryRepository = inventoryRepository;
        this.kafkaTemplate = kafkaTemplate;
    }

    public Inventory getInventoryByProductId(Long productId) {
        return inventoryRepository.findByProductId(productId)
                .orElseThrow(() -> new InventoryNotFoundException(productId));
    }

    public List<Inventory> getAllInventory() {
        return inventoryRepository.findAll();
    }

    public List<Inventory> getLowStockItems() {
        return inventoryRepository.findLowStockItems();
    }

    @Transactional
    public Inventory reserveStock(Long productId, Integer quantity) {
        Inventory inventory = inventoryRepository.findByProductId(productId)
                .orElseThrow(() -> new InventoryNotFoundException(productId));

        if (inventory.getAvailableStock() < quantity) {
            throw new InsufficientStockException(
                    inventory.getProductName(),
                    quantity,
                    inventory.getAvailableStock()
            );
        }

        // Reserve stock
        inventory.setAvailableStock(inventory.getAvailableStock() - quantity);
        inventory.setReservedStock(inventory.getReservedStock() + quantity);

        Inventory saved = inventoryRepository.save(inventory);

        // Check if low stock alert needed
        if (saved.getAvailableStock() < saved.getLowStockThreshold()) {
            publishLowStockAlert(saved);
        }

        return saved;
    }

    @Transactional
    public Inventory releaseStock(Long productId, Integer quantity) {
        Inventory inventory = inventoryRepository.findByProductId(productId)
                .orElseThrow(() -> new InventoryNotFoundException(productId));

        // Release stock back to available
        inventory.setReservedStock(Math.max(0, inventory.getReservedStock() - quantity));
        inventory.setAvailableStock(inventory.getAvailableStock() + quantity);

        return inventoryRepository.save(inventory);
    }

    @Transactional
    public Inventory confirmReservation(Long productId, Integer quantity) {
        Inventory inventory = inventoryRepository.findByProductId(productId)
                .orElseThrow(() -> new InventoryNotFoundException(productId));

        // Decrease total stock (item sold)
        inventory.setReservedStock(Math.max(0, inventory.getReservedStock() - quantity));
        inventory.setTotalStock(Math.max(0, inventory.getTotalStock() - quantity));

        return inventoryRepository.save(inventory);
    }

    @Transactional
    public void initializeInventory(Long productId, String productName, Integer stock) {
        if (inventoryRepository.findByProductId(productId).isEmpty()) {
            Inventory inventory = new Inventory(productId, productName, stock);
            inventoryRepository.save(inventory);
        }
    }

    @Transactional
    public void updateInventory(Long productId, String productName, Integer newTotalStock) {
        Inventory inventory = inventoryRepository.findByProductId(productId).orElse(null);
        
        if (inventory != null) {
            int diff = newTotalStock - inventory.getTotalStock();
            inventory.setProductName(productName);
            inventory.setTotalStock(newTotalStock);
            inventory.setAvailableStock(inventory.getAvailableStock() + diff);
            inventoryRepository.save(inventory);
        } else {
            // Initialize if not exists
            initializeInventory(productId, productName, newTotalStock);
        }
    }

    @Transactional
    public void deleteInventory(Long productId) {
        inventoryRepository.findByProductId(productId)
                .ifPresent(inventoryRepository::delete);
    }

    private void publishLowStockAlert(Inventory inventory) {
        Map<String, Object> alert = new HashMap<>();
        alert.put("productId", inventory.getProductId());
        alert.put("productName", inventory.getProductName());
        alert.put("availableStock", inventory.getAvailableStock());
        alert.put("threshold", inventory.getLowStockThreshold());
        alert.put("message", "Low stock alert: " + inventory.getProductName() + 
                  " has only " + inventory.getAvailableStock() + " units remaining");

        kafkaTemplate.send("low-stock-alert", inventory.getProductId().toString(), alert);
    }
}
