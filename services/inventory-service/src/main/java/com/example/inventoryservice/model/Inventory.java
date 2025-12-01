package com.example.inventoryservice.model;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "inventory")
public class Inventory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private Long productId;

    private String productName;

    private Integer availableStock = 0;

    private Integer reservedStock = 0;

    private Integer totalStock = 0;

    private Integer lowStockThreshold = 10;

    @Version
    private Long version; // For optimistic locking

    private Instant createdAt = Instant.now();

    private Instant updatedAt = Instant.now();

    public Inventory() {}

    public Inventory(Long productId, String productName, Integer totalStock) {
        this.productId = productId;
        this.productName = productName;
        this.totalStock = totalStock;
        this.availableStock = totalStock;
        this.reservedStock = 0;
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = Instant.now();
    }

    // Getters and setters

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public Integer getAvailableStock() { return availableStock; }
    public void setAvailableStock(Integer availableStock) { this.availableStock = availableStock; }

    public Integer getReservedStock() { return reservedStock; }
    public void setReservedStock(Integer reservedStock) { this.reservedStock = reservedStock; }

    public Integer getTotalStock() { return totalStock; }
    public void setTotalStock(Integer totalStock) { this.totalStock = totalStock; }

    public Integer getLowStockThreshold() { return lowStockThreshold; }
    public void setLowStockThreshold(Integer lowStockThreshold) { this.lowStockThreshold = lowStockThreshold; }

    public Long getVersion() { return version; }
    public void setVersion(Long version) { this.version = version; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
