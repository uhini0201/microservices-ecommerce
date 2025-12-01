package com.example.notificationservice.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class KafkaConsumerService {

    private static final Logger logger = LoggerFactory.getLogger(KafkaConsumerService.class);

    @Autowired
    private NotificationService notificationService;

    @KafkaListener(topics = "order-created", groupId = "notification-service-group")
    public void consumeOrderCreated(Map<String, Object> order) {
        logger.info("Consumed order-created event: {}", order);
        String orderId = order.get("id") != null ? order.get("id").toString() : "unknown";
        String customer = order.get("customer") != null ? order.get("customer").toString() : "Unknown";
        String amount = order.get("amount") != null ? order.get("amount").toString() : "0";
        
        String message = String.format("New order created by %s for $%s", customer, amount);
        notificationService.broadcastNotification("order-created", orderId, message, order);
    }

    @KafkaListener(topics = "product-created", groupId = "notification-service-group")
    public void consumeProductCreated(Map<String, Object> product) {
        logger.info("Consumed product-created event: {}", product);
        String productId = product.get("id") != null ? product.get("id").toString() : "unknown";
        String name = product.get("name") != null ? product.get("name").toString() : "Unknown Product";
        String price = product.get("price") != null ? product.get("price").toString() : "0";
        
        String message = String.format("New product '%s' added at $%s", name, price);
        notificationService.broadcastNotification("product-created", productId, message, product);
    }

    @KafkaListener(topics = "product-updated", groupId = "notification-service-group")
    public void consumeProductUpdated(Map<String, Object> product) {
        logger.info("Consumed product-updated event: {}", product);
        String productId = product.get("id") != null ? product.get("id").toString() : "unknown";
        String name = product.get("name") != null ? product.get("name").toString() : "Unknown Product";
        
        String message = String.format("Product '%s' has been updated", name);
        notificationService.broadcastNotification("product-updated", productId, message, product);
    }

    @KafkaListener(topics = "product-deleted", groupId = "notification-service-group")
    public void consumeProductDeleted(Map<String, Object> product) {
        logger.info("Consumed product-deleted event: {}", product);
        String productId = product.get("id") != null ? product.get("id").toString() : "unknown";
        String name = product.get("name") != null ? product.get("name").toString() : "Unknown Product";
        
        String message = String.format("Product '%s' has been deleted", name);
        notificationService.broadcastNotification("product-deleted", productId, message, product);
    }

    @KafkaListener(topics = "low-stock-alert", groupId = "notification-service-group")
    public void consumeLowStockAlert(Map<String, Object> alert) {
        logger.info("Consumed low-stock-alert event: {}", alert);
        String productId = alert.get("productId") != null ? alert.get("productId").toString() : "unknown";
        String productName = alert.get("productName") != null ? alert.get("productName").toString() : "Unknown Product";
        String availableStock = alert.get("availableStock") != null ? alert.get("availableStock").toString() : "0";
        String threshold = alert.get("threshold") != null ? alert.get("threshold").toString() : "10";
        
        String message = String.format("⚠️ LOW STOCK ALERT: '%s' has only %s units remaining (threshold: %s)", 
                                      productName, availableStock, threshold);
        notificationService.broadcastNotification("low-stock-alert", productId, message, alert);
    }
}
