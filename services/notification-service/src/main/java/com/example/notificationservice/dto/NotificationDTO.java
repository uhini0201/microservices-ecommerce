package com.example.notificationservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationDTO {
    private String eventType;
    private String entityId;
    private String message;
    private Object payload;
    private String timestamp;
}
