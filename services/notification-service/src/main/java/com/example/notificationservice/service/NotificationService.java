package com.example.notificationservice.service;

import java.io.IOException;
import java.time.Instant;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import com.example.notificationservice.dto.NotificationDTO;
import com.example.notificationservice.model.NotificationEvent;
import com.example.notificationservice.repo.NotificationRepository;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class NotificationService {

    private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);
    private final List<SseEmitter> emitters = new CopyOnWriteArrayList<>();

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private ObjectMapper objectMapper;

    public SseEmitter subscribe() {
        SseEmitter emitter = new SseEmitter(Long.MAX_VALUE);
        emitters.add(emitter);
        
        emitter.onCompletion(() -> {
            emitters.remove(emitter);
            logger.info("SSE connection completed. Active connections: {}", emitters.size());
        });
        
        emitter.onTimeout(() -> {
            emitters.remove(emitter);
            logger.info("SSE connection timed out. Active connections: {}", emitters.size());
        });
        
        emitter.onError((ex) -> {
            emitters.remove(emitter);
            logger.error("SSE connection error. Active connections: {}", emitters.size(), ex);
        });

        logger.info("New SSE subscription. Active connections: {}", emitters.size());
        return emitter;
    }

    public void broadcastNotification(String eventType, String entityId, String message, Object payload) {
        try {
            // Save to database
            NotificationEvent event = new NotificationEvent();
            event.setEventType(eventType);
            event.setEntityId(entityId);
            event.setMessage(message);
            event.setPayload(objectMapper.writeValueAsString(payload));
            notificationRepository.save(event);

            // Create DTO for SSE
            NotificationDTO dto = new NotificationDTO(
                eventType,
                entityId,
                message,
                payload,
                Instant.now().toString()
            );

            // Broadcast to all connected clients
            List<SseEmitter> deadEmitters = new CopyOnWriteArrayList<>();
            emitters.forEach(emitter -> {
                try {
                    emitter.send(SseEmitter.event()
                        .name("notification")
                        .data(dto));
                    logger.debug("Sent notification to client: {}", dto.getMessage());
                } catch (IOException e) {
                    deadEmitters.add(emitter);
                    logger.warn("Failed to send notification, removing emitter", e);
                }
            });

            emitters.removeAll(deadEmitters);
            logger.info("Broadcasted notification: {} - Active connections: {}", message, emitters.size());
        } catch (Exception e) {
            logger.error("Error broadcasting notification", e);
        }
    }

    public List<NotificationEvent> getRecentNotifications() {
        return notificationRepository.findTop100ByOrderByCreatedAtDesc();
    }

    public List<NotificationEvent> getNotificationsByType(String eventType) {
        return notificationRepository.findByEventTypeOrderByCreatedAtDesc(eventType);
    }
}
