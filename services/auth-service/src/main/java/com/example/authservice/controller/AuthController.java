package com.example.authservice.controller;

import com.example.authservice.dto.AuthResponse;
import com.example.authservice.dto.LoginRequest;
import com.example.authservice.dto.RefreshTokenRequest;
import com.example.authservice.dto.RegisterRequest;
import com.example.authservice.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        try {
            AuthResponse response = authService.register(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            AuthResponse response = authService.login(request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Invalid username or password");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
    }

    @PostMapping("/refresh")
    public ResponseEntity<?> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        try {
            AuthResponse response = authService.refreshToken(request.getRefreshToken());
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(@Valid @RequestBody RefreshTokenRequest request) {
        try {
            authService.logout(request.getRefreshToken());
            Map<String, String> response = new HashMap<>();
            response.put("message", "Logged out successfully");
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Auth service is running");
    }
}
