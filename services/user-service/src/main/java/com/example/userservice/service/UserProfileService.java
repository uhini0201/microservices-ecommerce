package com.example.userservice.service;

import com.example.userservice.dto.CreateUserProfileRequest;
import com.example.userservice.dto.UpdateUserProfileRequest;
import com.example.userservice.dto.UserProfileResponse;
import com.example.userservice.model.UserProfile;
import com.example.userservice.repository.UserProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserProfileService {
    
    @Autowired
    private UserProfileRepository userProfileRepository;
    
    @Transactional
    public UserProfileResponse createProfile(CreateUserProfileRequest request) {
        // Check if username already exists
        if (userProfileRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already exists");
        }
        
        // Check if email already exists
        if (userProfileRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }
        
        UserProfile profile = new UserProfile();
        profile.setUsername(request.getUsername());
        profile.setEmail(request.getEmail());
        profile.setFullName(request.getFullName());
        profile.setPhoneNumber(request.getPhoneNumber());
        profile.setAddress(request.getAddress());
        profile.setCity(request.getCity());
        profile.setState(request.getState());
        profile.setCountry(request.getCountry());
        profile.setPostalCode(request.getPostalCode());
        profile.setBio(request.getBio());
        profile.setAvatarUrl(request.getAvatarUrl());
        profile.setEmailNotifications(request.getEmailNotifications());
        profile.setSmsNotifications(request.getSmsNotifications());
        profile.setPushNotifications(request.getPushNotifications());
        profile.setPreferredLanguage(request.getPreferredLanguage());
        profile.setPreferredCurrency(request.getPreferredCurrency());
        
        UserProfile savedProfile = userProfileRepository.save(profile);
        return toResponse(savedProfile);
    }
    
    public UserProfileResponse getProfileByUsername(String username) {
        UserProfile profile = userProfileRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User profile not found"));
        return toResponse(profile);
    }
    
    public UserProfileResponse getProfileById(Long id) {
        UserProfile profile = userProfileRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User profile not found"));
        return toResponse(profile);
    }
    
    public List<UserProfileResponse> getAllProfiles() {
        return userProfileRepository.findAll().stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public UserProfileResponse updateProfile(String username, UpdateUserProfileRequest request) {
        UserProfile profile = userProfileRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User profile not found"));
        
        // Update only provided fields
        if (request.getEmail() != null) {
            // Check if new email is already taken by another user
            userProfileRepository.findByEmail(request.getEmail()).ifPresent(existing -> {
                if (!existing.getId().equals(profile.getId())) {
                    throw new RuntimeException("Email already exists");
                }
            });
            profile.setEmail(request.getEmail());
        }
        
        if (request.getFullName() != null) profile.setFullName(request.getFullName());
        if (request.getPhoneNumber() != null) profile.setPhoneNumber(request.getPhoneNumber());
        if (request.getAddress() != null) profile.setAddress(request.getAddress());
        if (request.getCity() != null) profile.setCity(request.getCity());
        if (request.getState() != null) profile.setState(request.getState());
        if (request.getCountry() != null) profile.setCountry(request.getCountry());
        if (request.getPostalCode() != null) profile.setPostalCode(request.getPostalCode());
        if (request.getBio() != null) profile.setBio(request.getBio());
        if (request.getAvatarUrl() != null) profile.setAvatarUrl(request.getAvatarUrl());
        if (request.getEmailNotifications() != null) profile.setEmailNotifications(request.getEmailNotifications());
        if (request.getSmsNotifications() != null) profile.setSmsNotifications(request.getSmsNotifications());
        if (request.getPushNotifications() != null) profile.setPushNotifications(request.getPushNotifications());
        if (request.getPreferredLanguage() != null) profile.setPreferredLanguage(request.getPreferredLanguage());
        if (request.getPreferredCurrency() != null) profile.setPreferredCurrency(request.getPreferredCurrency());
        
        UserProfile updatedProfile = userProfileRepository.save(profile);
        return toResponse(updatedProfile);
    }
    
    @Transactional
    public void deleteProfile(String username) {
        UserProfile profile = userProfileRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User profile not found"));
        userProfileRepository.delete(profile);
    }
    
    private UserProfileResponse toResponse(UserProfile profile) {
        return new UserProfileResponse(
                profile.getId(),
                profile.getUsername(),
                profile.getEmail(),
                profile.getFullName(),
                profile.getPhoneNumber(),
                profile.getAddress(),
                profile.getCity(),
                profile.getState(),
                profile.getCountry(),
                profile.getPostalCode(),
                profile.getBio(),
                profile.getAvatarUrl(),
                profile.getEmailNotifications(),
                profile.getSmsNotifications(),
                profile.getPushNotifications(),
                profile.getPreferredLanguage(),
                profile.getPreferredCurrency(),
                profile.getCreatedAt(),
                profile.getUpdatedAt()
        );
    }
}
