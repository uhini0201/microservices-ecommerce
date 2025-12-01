package com.example.inventoryservice.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public class ReserveStockRequest {

    @NotNull
    private Long productId;

    @NotNull
    @Min(1)
    private Integer quantity;

    private String orderId; // Optional: for tracking

    public ReserveStockRequest() {}

    public ReserveStockRequest(Long productId, Integer quantity) {
        this.productId = productId;
        this.quantity = quantity;
    }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public String getOrderId() { return orderId; }
    public void setOrderId(String orderId) { this.orderId = orderId; }
}
