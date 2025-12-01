package com.example.orderservice.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class OrderRequest {

    @NotBlank
    private String customer;

    @NotNull
    private Long productId;

    @NotNull
    @Min(1)
    private Integer quantity;

    public OrderRequest() {}

    public OrderRequest(String customer, Long productId, Integer quantity) {
        this.customer = customer;
        this.productId = productId;
        this.quantity = quantity;
    }

    public String getCustomer() { return customer; }
    public void setCustomer(String customer) { this.customer = customer; }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
}
