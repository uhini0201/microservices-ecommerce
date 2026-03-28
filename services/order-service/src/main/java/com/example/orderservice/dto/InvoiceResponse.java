package com.example.orderservice.dto;

import com.example.orderservice.model.Order;
import com.example.orderservice.model.OrderItem;

import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

public class InvoiceResponse {
    private String invoiceNumber;
    private String invoiceDate;
    private String customerName;
    private Long orderId;
    private String orderStatus;
    private List<InvoiceItem> items;
    private Double subtotal;
    private Double tax;
    private Double totalAmount;
    private String currency = "INR";
    private String taxRate = "18%";

    public InvoiceResponse() {}

    public InvoiceResponse(Order order) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss")
                .withZone(ZoneId.of("Asia/Kolkata"));
        
        this.invoiceNumber = "INV-" + order.getId() + "-" + 
                order.getCreatedAt().toEpochMilli();
        this.invoiceDate = formatter.format(order.getCreatedAt());
        this.customerName = order.getCustomer();
        this.orderId = order.getId();
        this.orderStatus = order.getStatus();
        
        // Calculate subtotal (without tax)
        this.subtotal = order.getTotalAmount() / 1.18; // Assuming 18% GST included
        this.tax = order.getTotalAmount() - this.subtotal;
        this.totalAmount = order.getTotalAmount();
        
        this.items = order.getItems().stream()
                .map(InvoiceItem::new)
                .collect(Collectors.toList());
    }

    // Getters and Setters
    public String getInvoiceNumber() { return invoiceNumber; }
    public void setInvoiceNumber(String invoiceNumber) { this.invoiceNumber = invoiceNumber; }

    public String getInvoiceDate() { return invoiceDate; }
    public void setInvoiceDate(String invoiceDate) { this.invoiceDate = invoiceDate; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }

    public String getOrderStatus() { return orderStatus; }
    public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }

    public List<InvoiceItem> getItems() { return items; }
    public void setItems(List<InvoiceItem> items) { this.items = items; }

    public Double getSubtotal() { return subtotal; }
    public void setSubtotal(Double subtotal) { this.subtotal = subtotal; }

    public Double getTax() { return tax; }
    public void setTax(Double tax) { this.tax = tax; }

    public Double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(Double totalAmount) { this.totalAmount = totalAmount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public String getTaxRate() { return taxRate; }
    public void setTaxRate(String taxRate) { this.taxRate = taxRate; }

    public static class InvoiceItem {
        private String productName;
        private Integer quantity;
        private Double unitPrice;
        private Double subtotal;

        public InvoiceItem() {}

        public InvoiceItem(OrderItem item) {
            this.productName = item.getProductName();
            this.quantity = item.getQuantity();
            this.unitPrice = item.getUnitPrice();
            this.subtotal = item.getSubtotal();
        }

        // Getters and Setters
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }

        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }

        public Double getUnitPrice() { return unitPrice; }
        public void setUnitPrice(Double unitPrice) { this.unitPrice = unitPrice; }

        public Double getSubtotal() { return subtotal; }
        public void setSubtotal(Double subtotal) { this.subtotal = subtotal; }
    }
}
