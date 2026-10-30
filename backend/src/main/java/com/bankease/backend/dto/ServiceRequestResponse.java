package com.bankease.backend.dto;

import com.bankease.backend.entity.ServiceRequest;
import com.bankease.backend.entity.ServiceRequestPriority;
import com.bankease.backend.entity.ServiceRequestStatus;
import com.bankease.backend.entity.ServiceRequestType;

import java.time.LocalDateTime;

public class ServiceRequestResponse {

    private Long id;
    private ServiceRequestType type;
    private ServiceRequestStatus status;
    private ServiceRequestPriority priority;
    private String description;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long customerId;
    private String customerName;

    public ServiceRequestResponse() {
    }

    public static ServiceRequestResponse fromEntity(
            ServiceRequest serviceRequest
    ) {

        ServiceRequestResponse response =
                new ServiceRequestResponse();

        response.id = serviceRequest.getId();
        response.type = serviceRequest.getType();
        response.status = serviceRequest.getStatus();
        response.priority = serviceRequest.getPriority();
        response.description = serviceRequest.getDescription();
        response.createdAt = serviceRequest.getCreatedAt();
        response.updatedAt = serviceRequest.getUpdatedAt();

        if (serviceRequest.getCustomer() != null) {
            response.customerId =
                    serviceRequest.getCustomer().getId();

            response.customerName =
                    serviceRequest.getCustomer().getFullName();
        }

        return response;
    }

    public Long getId() {
        return id;
    }

    public ServiceRequestType getType() {
        return type;
    }

    public ServiceRequestStatus getStatus() {
        return status;
    }

    public ServiceRequestPriority getPriority() {
        return priority;
    }

    public String getDescription() {
        return description;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public Long getCustomerId() {
        return customerId;
    }

    public String getCustomerName() {
        return customerName;
    }
}