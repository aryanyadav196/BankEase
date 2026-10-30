package com.bankease.backend.dto;

import com.bankease.backend.entity.ServiceRequestType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class CreateServiceRequestRequest {

    @NotNull
    private ServiceRequestType type;

    @NotBlank
    private String description;

    public CreateServiceRequestRequest() {
    }

    public ServiceRequestType getType() {
        return type;
    }

    public void setType(ServiceRequestType type) {
        this.type = type;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}