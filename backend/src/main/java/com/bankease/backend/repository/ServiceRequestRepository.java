package com.bankease.backend.repository;

import com.bankease.backend.entity.ServiceRequest;
import com.bankease.backend.entity.ServiceRequestPriority;
import com.bankease.backend.entity.ServiceRequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface ServiceRequestRepository
        extends JpaRepository<ServiceRequest, Long> {

    List<ServiceRequest> findByCustomerId(Long customerId);

    List<ServiceRequest> findByStatus(ServiceRequestStatus status);

    List<ServiceRequest> findAllByOrderByCreatedAtDesc();

    List<ServiceRequest> findByStatusAndCreatedAtBefore(
            ServiceRequestStatus status,
            LocalDateTime createdBefore
    );

    List<ServiceRequest> findByPriorityAndStatus(
            ServiceRequestPriority priority,
            ServiceRequestStatus status
    );
}