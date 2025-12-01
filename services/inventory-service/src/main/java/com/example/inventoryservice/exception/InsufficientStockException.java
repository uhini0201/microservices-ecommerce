package com.example.inventoryservice.exception;

public class InsufficientStockException extends RuntimeException {
    public InsufficientStockException(String productName, Integer requested, Integer available) {
        super("Insufficient stock for product '" + productName + "'. Requested: " + requested + ", Available: " + available);
    }
}
