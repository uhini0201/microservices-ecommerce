package com.example.productservice.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import com.example.productservice.dto.ProductRequest;
import com.example.productservice.model.Product;
import com.example.productservice.repo.ProductRepository;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;

    public Product createProduct(ProductRequest request) {
        Product product = new Product();
        product.setName(request.getName());
        product.setDescription(request.getDescription());
        product.setPrice(request.getPrice());
        product.setStock(request.getStock());
        
        Product saved = productRepository.save(product);
        
        // Publish event to Kafka
        kafkaTemplate.send("product-created", saved.getId().toString(), saved);
        
        return saved;
    }

    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    public Product getProductById(Long id) {
        return productRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
    }

    public Product updateProduct(Long id, ProductRequest request) {
        Product product = getProductById(id);
        product.setName(request.getName());
        product.setDescription(request.getDescription());
        product.setPrice(request.getPrice());
        product.setStock(request.getStock());
        
        Product updated = productRepository.save(product);
        
        // Publish event to Kafka
        kafkaTemplate.send("product-updated", updated.getId().toString(), updated);
        
        return updated;
    }

    public void deleteProduct(Long id) {
        Product product = getProductById(id);
        productRepository.delete(product);
        
        // Publish event to Kafka
        kafkaTemplate.send("product-deleted", id.toString(), product);
    }
}
