package com.example.userservice.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_profiles")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserProfile {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String username;  // Links to auth-service user
    
    @Column(nullable = false)
    private String email;
    
    private String fullName;
    
    private String phoneNumber;
    
    private String address;
    
    private String city;
    
    private String state;
    
    private String country;
    
    private String postalCode;
    
    @Column(length = 1000)
    private String bio;
    
    private String avatarUrl;
    
    @Column(name = "email_notifications", nullable = false)
    private Boolean emailNotifications = true;
    
    @Column(name = "sms_notifications", nullable = false)
    private Boolean smsNotifications = false;
    
    @Column(name = "push_notifications", nullable = false)
    private Boolean pushNotifications = true;
    
    private String preferredLanguage = "en";
    
    private String preferredCurrency = "USD";
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
