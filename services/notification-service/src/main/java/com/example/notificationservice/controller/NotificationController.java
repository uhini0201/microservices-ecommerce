package com.example.notificationservice.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import com.example.notificationservice.model.NotificationEvent;
import com.example.notificationservice.service.NotificationService;

@RestController
@RequestMapping("/notifications")
@CrossOrigin(origins = "*") // Enable CORS for frontend
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter streamNotifications() {
        return notificationService.subscribe();
    }

    @GetMapping("/recent")
    public ResponseEntity<List<NotificationEvent>> getRecentNotifications() {
        List<NotificationEvent> notifications = notificationService.getRecentNotifications();
        return ResponseEntity.ok(notifications);
    }

    @GetMapping("/type/{eventType}")
    public ResponseEntity<List<NotificationEvent>> getNotificationsByType(@PathVariable String eventType) {
        List<NotificationEvent> notifications = notificationService.getNotificationsByType(eventType);
        return ResponseEntity.ok(notifications);
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Notification service is running");
    }
}
