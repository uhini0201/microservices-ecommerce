package com.example.productservice.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.productservice.model.Product;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
}
