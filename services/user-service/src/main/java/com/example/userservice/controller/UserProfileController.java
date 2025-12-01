package com.example.userservice.controller;

import com.example.userservice.dto.CreateUserProfileRequest;
import com.example.userservice.dto.UpdateUserProfileRequest;
import com.example.userservice.dto.UserProfileResponse;
import com.example.userservice.service.UserProfileService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/users")
@CrossOrigin(origins = "*")
public class UserProfileController {
    
    @Autowired
    private UserProfileService userProfileService;
    
    @GetMapping("/health")
    public String health() {
        return "User service is running";
    }
    
    /**
     * Create a new user profile
     */
    @PostMapping
    public ResponseEntity<?> createProfile(@Valid @RequestBody CreateUserProfileRequest request) {
        try {
            UserProfileResponse response = userProfileService.createProfile(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    /**
     * Get current user's profile (from JWT token)
     */
    @GetMapping("/me")
    public ResponseEntity<?> getMyProfile() {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String username = authentication.getName();
            
            UserProfileResponse response = userProfileService.getProfileByUsername(username);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", e.getMessage()));
        }
    }
    
    /**
     * Get all user profiles (admin function)
     */
    @GetMapping
    public ResponseEntity<List<UserProfileResponse>> getAllProfiles() {
        List<UserProfileResponse> profiles = userProfileService.getAllProfiles();
        return ResponseEntity.ok(profiles);
    }
    
    /**
     * Get user profile by username
     */
    @GetMapping("/{username}")
    public ResponseEntity<?> getProfileByUsername(@PathVariable String username) {
        try {
            UserProfileResponse response = userProfileService.getProfileByUsername(username);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", e.getMessage()));
        }
    }
    
    /**
     * Update current user's profile
     */
    @PutMapping("/me")
    public ResponseEntity<?> updateMyProfile(@Valid @RequestBody UpdateUserProfileRequest request) {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String username = authentication.getName();
            
            UserProfileResponse response = userProfileService.updateProfile(username, request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    /**
     * Update user profile by username (admin function)
     */
    @PutMapping("/{username}")
    public ResponseEntity<?> updateProfile(
            @PathVariable String username,
            @Valid @RequestBody UpdateUserProfileRequest request) {
        try {
            UserProfileResponse response = userProfileService.updateProfile(username, request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    /**
     * Delete current user's profile
     */
    @DeleteMapping("/me")
    public ResponseEntity<?> deleteMyProfile() {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String username = authentication.getName();
            
            userProfileService.deleteProfile(username);
            return ResponseEntity.ok(Map.of("message", "Profile deleted successfully"));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", e.getMessage()));
        }
    }
    
    /**
     * Delete user profile by username (admin function)
     */
    @DeleteMapping("/{username}")
    public ResponseEntity<?> deleteProfile(@PathVariable String username) {
        try {
            userProfileService.deleteProfile(username);
            return ResponseEntity.ok(Map.of("message", "Profile deleted successfully"));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(Map.of("error", e.getMessage()));
        }
    }
}
