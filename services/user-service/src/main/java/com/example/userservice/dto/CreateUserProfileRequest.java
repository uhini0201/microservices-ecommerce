package com.example.userservice.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CreateUserProfileRequest {
    
    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be between 3 and 50 characters")
    private String username;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    @Size(max = 100, message = "Email must not exceed 100 characters")
    private String email;
    
    @Size(max = 100, message = "Full name must not exceed 100 characters")
    private String fullName;
    
    @Size(max = 20, message = "Phone number must not exceed 20 characters")
    private String phoneNumber;
    
    @Size(max = 200, message = "Address must not exceed 200 characters")
    private String address;
    
    @Size(max = 50, message = "City must not exceed 50 characters")
    private String city;
    
    @Size(max = 50, message = "State must not exceed 50 characters")
    private String state;
    
    @Size(max = 50, message = "Country must not exceed 50 characters")
    private String country;
    
    @Size(max = 20, message = "Postal code must not exceed 20 characters")
    private String postalCode;
    
    @Size(max = 1000, message = "Bio must not exceed 1000 characters")
    private String bio;
    
    private String avatarUrl;
    
    private Boolean emailNotifications = true;
    private Boolean smsNotifications = false;
    private Boolean pushNotifications = true;
    
    private String preferredLanguage = "en";
    private String preferredCurrency = "USD";
}
