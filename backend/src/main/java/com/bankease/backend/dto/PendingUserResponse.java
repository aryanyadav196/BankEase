package com.bankease.backend.dto;

import com.bankease.backend.entity.User;

public class PendingUserResponse {

    private Long id;
    private String email;
    private String role;
    private String status;

    public PendingUserResponse() {
    }

    public static PendingUserResponse fromEntity(User user) {
        PendingUserResponse response = new PendingUserResponse();
        response.id = user.getId();
        response.email = user.getEmail();
        response.role = user.getRole().name();
        response.status = user.isActive() ? "ACTIVE" : "PENDING";
        return response;
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getRole() {
        return role;
    }

    public String getStatus() {
        return status;
    }
}
