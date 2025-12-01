package com.example.authservice.service;

import com.example.authservice.dto.AuthResponse;
import com.example.authservice.dto.LoginRequest;
import com.example.authservice.dto.RegisterRequest;
import com.example.authservice.model.RefreshToken;
import com.example.authservice.model.User;
import com.example.authservice.repository.RefreshTokenRepository;
import com.example.authservice.repository.UserRepository;
import com.example.authservice.security.JwtUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtUtils jwtUtils;

    @Value("${jwt.expiration}")
    private long jwtExpirationMs;

    @Value("${jwt.refresh-expiration}")
    private long refreshExpirationMs;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        // Check if username already exists
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        // Check if email already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email already exists");
        }

        // Parse role, default to USER
        User.Role role = User.Role.USER;
        if (request.getRole() != null && !request.getRole().isEmpty()) {
            try {
                role = User.Role.valueOf(request.getRole().toUpperCase());
            } catch (IllegalArgumentException e) {
                logger.warn("Invalid role '{}', defaulting to USER", request.getRole());
            }
        }

        // Create new user
        User user = new User(
                request.getUsername(),
                request.getEmail(),
                passwordEncoder.encode(request.getPassword()),
                role
        );

        userRepository.save(user);
        logger.info("User registered successfully: {}", user.getUsername());

        // Generate tokens
        String accessToken = jwtUtils.generateJwtToken(user.getUsername());
        String refreshToken = jwtUtils.generateRefreshToken(user.getUsername());

        // Save refresh token
        RefreshToken refreshTokenEntity = new RefreshToken(
                user,
                refreshToken,
                LocalDateTime.now().plusSeconds(refreshExpirationMs / 1000)
        );
        refreshTokenRepository.save(refreshTokenEntity);

        return new AuthResponse(
                accessToken,
                refreshToken,
                jwtExpirationMs / 1000,
                user.getUsername(),
                user.getRole().name()
        );
    }

    @Transactional
    public AuthResponse login(LoginRequest request) {
        // Authenticate user
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);

        // Get user
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Generate tokens
        String accessToken = jwtUtils.generateJwtToken(authentication);
        String refreshToken = jwtUtils.generateRefreshToken(user.getUsername());

        // Delete old refresh tokens for this user (commented out to avoid transaction issues for now)
        // refreshTokenRepository.deleteByUser(user);

        // Save new refresh token
        RefreshToken refreshTokenEntity = new RefreshToken(
                user,
                refreshToken,
                LocalDateTime.now().plusSeconds(refreshExpirationMs / 1000)
        );
        refreshTokenRepository.save(refreshTokenEntity);

        logger.info("User logged in successfully: {}", user.getUsername());

        return new AuthResponse(
                accessToken,
                refreshToken,
                jwtExpirationMs / 1000,
                user.getUsername(),
                user.getRole().name()
        );
    }

    public AuthResponse refreshToken(String refreshTokenStr) {
        // Find refresh token
        RefreshToken refreshToken = refreshTokenRepository.findByToken(refreshTokenStr)
                .orElseThrow(() -> new RuntimeException("Invalid refresh token"));

        // Check if expired
        if (refreshToken.isExpired()) {
            refreshTokenRepository.delete(refreshToken);
            throw new RuntimeException("Refresh token expired");
        }

        // Get user
        User user = refreshToken.getUser();

        // Generate new access token
        String newAccessToken = jwtUtils.generateJwtToken(user.getUsername());

        logger.info("Token refreshed for user: {}", user.getUsername());

        return new AuthResponse(
                newAccessToken,
                refreshTokenStr,
                jwtExpirationMs / 1000,
                user.getUsername(),
                user.getRole().name()
        );
    }

    @Transactional
    public void logout(String refreshToken) {
        refreshTokenRepository.deleteByToken(refreshToken);
        logger.info("User logged out, refresh token invalidated");
    }
}
