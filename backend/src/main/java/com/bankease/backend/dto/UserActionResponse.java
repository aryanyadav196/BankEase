package com.bankease.backend.dto;

public class UserActionResponse {

    private String message;

    public UserActionResponse() {
    }

    public UserActionResponse(String message) {
        this.message = message;
    }

    public String getMessage() {
        return message;
    }
}
