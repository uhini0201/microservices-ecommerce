package com.example.orderservice.model;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "orders")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String customer;

    private Long productId;

    private String productName;

    private Integer quantity;

    private Double unitPrice;

    private Double totalAmount;

    private String status;

    private Instant createdAt = Instant.now();

    public Order() {}

    public Order(String customer, Long productId, String productName, Integer quantity, Double unitPrice, Double totalAmount, String status) {
        this.customer = customer;
        this.productId = productId;
        this.productName = productName;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.totalAmount = totalAmount;
        this.status = status;
    }

    // getters and setters

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCustomer() { return customer; }
    public void setCustomer(String customer) { this.customer = customer; }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public Double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(Double unitPrice) { this.unitPrice = unitPrice; }

    public Double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(Double totalAmount) { this.totalAmount = totalAmount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}
