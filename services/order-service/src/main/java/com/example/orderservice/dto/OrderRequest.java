package com.example.orderservice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;

public class OrderRequest {

    @NotBlank
    private String customer;

    @NotEmpty
    private List<OrderItemRequest> items;

    public OrderRequest() {}

    public OrderRequest(String customer, List<OrderItemRequest> items) {
        this.customer = customer;
        this.items = items;
    }

    public String getCustomer() { return customer; }
    public void setCustomer(String customer) { this.customer = customer; }

    public List<OrderItemRequest> getItems() { return items; }
    public void setItems(List<OrderItemRequest> items) { this.items = items; }
}

