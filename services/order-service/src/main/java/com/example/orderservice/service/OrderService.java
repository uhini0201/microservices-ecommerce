package com.example.orderservice.service;

import com.example.orderservice.client.InventoryClient;
import com.example.orderservice.client.ProductClient;
import com.example.orderservice.dto.OrderRequest;
import com.example.orderservice.dto.ProductDTO;
import com.example.orderservice.exception.InsufficientStockException;
import com.example.orderservice.model.Order;
import com.example.orderservice.repo.OrderRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OrderService {

    private static final Logger logger = LoggerFactory.getLogger(OrderService.class);

    private final OrderRepository orderRepository;
    private final ProductClient productClient;
    private final InventoryClient inventoryClient;
    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final String topic = "order-created";

    public OrderService(OrderRepository orderRepository, 
                       ProductClient productClient, 
                       InventoryClient inventoryClient,
                       KafkaTemplate<String, Object> kafkaTemplate) {
        this.orderRepository = orderRepository;
        this.productClient = productClient;
        this.inventoryClient = inventoryClient;
        this.kafkaTemplate = kafkaTemplate;
    }

    @Transactional
    public Order createOrder(OrderRequest request) {
        // Step 1: Fetch product details from product-service
        logger.info("Creating order for customer: {}, product: {}, quantity: {}", 
                   request.getCustomer(), request.getProductId(), request.getQuantity());
        
        ProductDTO product = productClient.getProduct(request.getProductId());
        logger.info("Product fetched: {} (Price: ${})", product.getName(), product.getPrice());

        // Step 2: Reserve stock in inventory-service
        try {
            inventoryClient.reserveStock(request.getProductId(), request.getQuantity());
            logger.info("Stock reserved successfully for product {}", request.getProductId());
        } catch (Exception e) {
            logger.error("Failed to reserve stock: {}", e.getMessage());
            throw e;
        }

        // Step 3: Calculate total amount
        Double unitPrice = product.getPrice();
        Double totalAmount = unitPrice * request.getQuantity();

        // Step 4: Create and save order
        Order order = new Order(
                request.getCustomer(),
                product.getId(),
                product.getName(),
                request.getQuantity(),
                unitPrice,
                totalAmount,
                "CREATED"
        );

        Order saved = orderRepository.save(order);
        logger.info("Order created successfully: ID {}, Total: ${}", saved.getId(), totalAmount);

        // Step 5: Publish to Kafka
        kafkaTemplate.send(topic, saved.getId().toString(), saved);

        return saved;
    }

    public Order getOrder(Long id) {
        return orderRepository.findById(id).orElse(null);
    }
}
