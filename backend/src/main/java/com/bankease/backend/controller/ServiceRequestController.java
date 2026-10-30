package com.bankease.backend.controller;

import com.bankease.backend.dto.CreateServiceRequestRequest;
import com.bankease.backend.dto.ServiceRequestResponse;
import com.bankease.backend.service.ServiceRequestService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/service-requests")
public class ServiceRequestController {

    private final ServiceRequestService serviceRequestService;

    public ServiceRequestController(
            ServiceRequestService serviceRequestService
    ) {
        this.serviceRequestService =
                serviceRequestService;
    }

    @PreAuthorize("hasAnyRole('CUSTOMER', 'EMPLOYEE', 'ADMIN')")
    @PostMapping
    public ResponseEntity<ServiceRequestResponse> createRequest(
            @RequestParam Long customerId,
            @Valid @RequestBody CreateServiceRequestRequest request,
            Authentication authentication
    ) {

        ServiceRequestResponse response =
                serviceRequestService.createRequest(
                        customerId,
                        request,
                        authentication
                );

        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasAnyRole('CUSTOMER', 'EMPLOYEE', 'ADMIN')")
    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<ServiceRequestResponse>> getCustomerRequests(
            @PathVariable Long customerId,
            Authentication authentication
    ) {

        List<ServiceRequestResponse> requests =
                serviceRequestService.getCustomerRequests(
                        customerId,
                        authentication
                );

        return ResponseEntity.ok(requests);
    }

    @PreAuthorize("hasAnyRole('EMPLOYEE', 'ADMIN')")
    @GetMapping
    public ResponseEntity<List<ServiceRequestResponse>> getAllRequests() {

        List<ServiceRequestResponse> requests =
                serviceRequestService.getAllRequests();

        return ResponseEntity.ok(requests);
    }

    @PreAuthorize("hasAnyRole('EMPLOYEE', 'ADMIN')")
    @PatchMapping("/{requestId}/start")
    public ResponseEntity<ServiceRequestResponse> startProcessing(
            @PathVariable Long requestId
    ) {

        ServiceRequestResponse response =
                serviceRequestService.startProcessing(
                        requestId
                );

        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasAnyRole('EMPLOYEE', 'ADMIN')")
    @PatchMapping("/{requestId}/resolve")
    public ResponseEntity<ServiceRequestResponse> resolveRequest(
            @PathVariable Long requestId
    ) {

        ServiceRequestResponse response =
                serviceRequestService.resolveRequest(
                        requestId
                );

        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasAnyRole('EMPLOYEE', 'ADMIN')")
    @PatchMapping("/{requestId}/reject")
    public ResponseEntity<ServiceRequestResponse> rejectRequest(
            @PathVariable Long requestId
    ) {

        ServiceRequestResponse response =
                serviceRequestService.rejectRequest(
                        requestId
                );

        return ResponseEntity.ok(response);
    }
}