package com.bankease.backend.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "service_requests")
public class ServiceRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private ServiceRequestType type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ServiceRequestStatus status;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ServiceRequestPriority priority;

    @Column(nullable = false, length = 500)
    private String description;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @ManyToOne
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    public ServiceRequest() {
    }

    public Long getId() {
        return id;
    }

    public ServiceRequestType getType() {
        return type;
    }

    public void setType(ServiceRequestType type) {
        this.type = type;
    }

    public ServiceRequestStatus getStatus() {
        return status;
    }

    public void setStatus(ServiceRequestStatus status) {
        this.status = status;
    }

    public ServiceRequestPriority getPriority() {
        return priority;
    }

    public void setPriority(ServiceRequestPriority priority) {
        this.priority = priority;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }
}