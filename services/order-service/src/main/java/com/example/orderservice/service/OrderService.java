package com.example.orderservice.service;

import com.example.orderservice.client.InventoryClient;
import com.example.orderservice.client.ProductClient;
import com.example.orderservice.dto.OrderItemRequest;
import com.example.orderservice.dto.OrderRequest;
import com.example.orderservice.dto.ProductDTO;
import com.example.orderservice.exception.InsufficientStockException;
import com.example.orderservice.model.Order;
import com.example.orderservice.model.OrderItem;
import com.example.orderservice.repo.OrderItemRepository;
import com.example.orderservice.repo.OrderRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
public class OrderService {

    private static final Logger logger = LoggerFactory.getLogger(OrderService.class);

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final ProductClient productClient;
    private final InventoryClient inventoryClient;
    private final KafkaTemplate<String, Object> kafkaTemplate;
    private final String topic = "order-created";

    public OrderService(OrderRepository orderRepository,
                       OrderItemRepository orderItemRepository,
                       ProductClient productClient, 
                       InventoryClient inventoryClient,
                       KafkaTemplate<String, Object> kafkaTemplate) {
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
        this.productClient = productClient;
        this.inventoryClient = inventoryClient;
        this.kafkaTemplate = kafkaTemplate;
    }

    @Transactional
    public Order createOrder(OrderRequest request) {
        logger.info("Creating order for customer: {} with {} items", 
                   request.getCustomer(), request.getItems().size());
        
        List<OrderItem> orderItems = new ArrayList<>();
        double totalAmount = 0.0;

        // Step 1: Process each item in the order
        for (OrderItemRequest itemRequest : request.getItems()) {
            // Fetch product details
            ProductDTO product = productClient.getProduct(itemRequest.getProductId());
            logger.info("Product fetched: {} (Price: ${})", product.getName(), product.getPrice());

            // Reserve stock
            try {
                inventoryClient.reserveStock(itemRequest.getProductId(), itemRequest.getQuantity());
                logger.info("Stock reserved for product {} (qty: {})", product.getId(), itemRequest.getQuantity());
            } catch (Exception e) {
                logger.error("Failed to reserve stock for product {}: {}", itemRequest.getProductId(), e.getMessage());
                throw e;
            }

            // Create order item (temporary, will be saved after order)
            OrderItem orderItem = new OrderItem(
                null, // orderId will be set after order is saved
                product.getId(),
                product.getName(),
                itemRequest.getQuantity(),
                product.getPrice()
            );
            orderItems.add(orderItem);
            totalAmount += orderItem.getSubtotal();
        }

        // Step 2: Create and save order
        Order order = new Order(request.getCustomer(), totalAmount, "CREATED");
        Order savedOrder = orderRepository.save(order);
        logger.info("Order created: ID {}, Total: ${}", savedOrder.getId(), totalAmount);

        // Step 3: Save order items with orderId
        for (OrderItem item : orderItems) {
            item.setOrderId(savedOrder.getId());
            orderItemRepository.save(item);
        }
        
        // Attach items to order for response
        savedOrder.setItems(orderItems);
        logger.info("Order items saved: {} items", orderItems.size());

        // Step 4: Publish to Kafka
        kafkaTemplate.send(topic, savedOrder.getId().toString(), savedOrder);

        return savedOrder;
    }

    public Order getOrder(Long id) {
        Order order = orderRepository.findById(id).orElse(null);
        if (order != null) {
            List<OrderItem> items = orderItemRepository.findByOrderId(id);
            order.setItems(items);
        }
        return order;
    }

    public java.util.List<Order> getOrdersByCustomer(String customer) {
        logger.info("Fetching orders for customer: {}", customer);
        List<Order> orders = orderRepository.findByCustomerOrderByCreatedAtDesc(customer);
        // Load items for each order
        for (Order order : orders) {
            List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
            order.setItems(items);
        }
        return orders;
    }

    @Transactional
    public Order cancelOrder(Long id, String customer) {
        logger.info("Attempting to cancel order {} for customer: {}", id, customer);
        
        Order order = getOrder(id);
        if (order == null) {
            throw new IllegalArgumentException("Order not found");
        }

        // Verify order belongs to customer
        if (!order.getCustomer().equals(customer)) {
            throw new IllegalStateException("Unauthorized: Order does not belong to this customer");
        }

        // Only allow canceling CREATED orders
        if (!"CREATED".equals(order.getStatus())) {
            throw new IllegalStateException("Can only cancel orders in CREATED status");
        }

        // Update status to CANCELLED
        order.setStatus("CANCELLED");
        Order savedOrder = orderRepository.save(order);
        logger.info("Order {} cancelled successfully", id);

        // Load items for response
        List<OrderItem> items = orderItemRepository.findByOrderId(id);
        savedOrder.setItems(items);

        return savedOrder;
    }
}
