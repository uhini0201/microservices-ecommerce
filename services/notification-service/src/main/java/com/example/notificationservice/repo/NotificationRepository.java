package com.example.notificationservice.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.notificationservice.model.NotificationEvent;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<NotificationEvent, Long> {
    List<NotificationEvent> findTop100ByOrderByCreatedAtDesc();
    List<NotificationEvent> findByEventTypeOrderByCreatedAtDesc(String eventType);
}
