package com.example.userservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {
    
    private Long id;
    private String username;
    private String email;
    private String fullName;
    private String phoneNumber;
    private String address;
    private String city;
    private String state;
    private String country;
    private String postalCode;
    private String bio;
    private String avatarUrl;
    private Boolean emailNotifications;
    private Boolean smsNotifications;
    private Boolean pushNotifications;
    private String preferredLanguage;
    private String preferredCurrency;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
