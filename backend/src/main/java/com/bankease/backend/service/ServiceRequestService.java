package com.bankease.backend.service;

import com.bankease.backend.dto.CreateServiceRequestRequest;
import com.bankease.backend.dto.ServiceRequestResponse;
import com.bankease.backend.entity.Customer;
import com.bankease.backend.entity.Role;
import com.bankease.backend.entity.ServiceRequest;
import com.bankease.backend.entity.ServiceRequestPriority;
import com.bankease.backend.entity.ServiceRequestStatus;
import com.bankease.backend.repository.CustomerRepository;
import com.bankease.backend.repository.ServiceRequestRepository;
import com.bankease.backend.security.CurrentUserService;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ServiceRequestService {

    private final ServiceRequestRepository serviceRequestRepository;
    private final CustomerRepository customerRepository;
    private final CurrentUserService currentUserService;

    public ServiceRequestService(
            ServiceRequestRepository serviceRequestRepository,
            CustomerRepository customerRepository,
            CurrentUserService currentUserService
    ) {
        this.serviceRequestRepository = serviceRequestRepository;
        this.customerRepository = customerRepository;
        this.currentUserService = currentUserService;
    }

    @Transactional
    public ServiceRequestResponse createRequest(
            Long customerId,
            CreateServiceRequestRequest request,
            Authentication authentication
    ) {

        Customer customer =
                getAuthorizedCustomer(
                        customerId,
                        authentication
                );

        ServiceRequest serviceRequest =
                new ServiceRequest();

        serviceRequest.setType(request.getType());

        serviceRequest.setDescription(
                request.getDescription()
        );

        serviceRequest.setStatus(
                ServiceRequestStatus.PENDING
        );

        serviceRequest.setPriority(
                ServiceRequestPriority.MEDIUM
        );

        serviceRequest.setCreatedAt(
                LocalDateTime.now()
        );

        serviceRequest.setUpdatedAt(
                LocalDateTime.now()
        );

        serviceRequest.setCustomer(customer);

        ServiceRequest savedRequest =
                serviceRequestRepository.save(
                        serviceRequest
                );

        return ServiceRequestResponse.fromEntity(
                savedRequest
        );
    }

    public List<ServiceRequestResponse> getCustomerRequests(
            Long customerId,
            Authentication authentication
    ) {

        getAuthorizedCustomer(
                customerId,
                authentication
        );

        return serviceRequestRepository
                .findByCustomerId(customerId)
                .stream()
                .map(ServiceRequestResponse::fromEntity)
                .toList();
    }

    public List<ServiceRequestResponse> getAllRequests() {

        return serviceRequestRepository
                .findAllByOrderByCreatedAtDesc()
                .stream()
                .map(ServiceRequestResponse::fromEntity)
                .toList();
    }

    @Transactional
    public ServiceRequestResponse startProcessing(
            Long requestId
    ) {

        ServiceRequest serviceRequest =
                findRequest(requestId);

        if (serviceRequest.getStatus()
                != ServiceRequestStatus.PENDING) {

            throw new IllegalStateException(
                    "Only pending service requests can be moved to in-progress."
            );
        }

        serviceRequest.setStatus(
                ServiceRequestStatus.IN_PROGRESS
        );

        serviceRequest.setUpdatedAt(
                LocalDateTime.now()
        );

        ServiceRequest savedRequest =
                serviceRequestRepository.save(
                        serviceRequest
                );

        return ServiceRequestResponse.fromEntity(
                savedRequest
        );
    }

    @Transactional
    public ServiceRequestResponse resolveRequest(
            Long requestId
    ) {

        ServiceRequest serviceRequest =
                findRequest(requestId);

        if (serviceRequest.getStatus()
                != ServiceRequestStatus.IN_PROGRESS) {

            throw new IllegalStateException(
                    "Only in-progress service requests can be resolved."
            );
        }

        serviceRequest.setStatus(
                ServiceRequestStatus.RESOLVED
        );

        serviceRequest.setUpdatedAt(
                LocalDateTime.now()
        );

        ServiceRequest savedRequest =
                serviceRequestRepository.save(
                        serviceRequest
                );

        return ServiceRequestResponse.fromEntity(
                savedRequest
        );
    }

    @Transactional
    public ServiceRequestResponse rejectRequest(
            Long requestId
    ) {

        ServiceRequest serviceRequest =
                findRequest(requestId);

        if (serviceRequest.getStatus()
                != ServiceRequestStatus.IN_PROGRESS) {

            throw new IllegalStateException(
                    "Only in-progress service requests can be rejected."
            );
        }

        serviceRequest.setStatus(
                ServiceRequestStatus.REJECTED
        );

        serviceRequest.setUpdatedAt(
                LocalDateTime.now()
        );

        ServiceRequest savedRequest =
                serviceRequestRepository.save(
                        serviceRequest
                );

        return ServiceRequestResponse.fromEntity(
                savedRequest
        );
    }

    private Customer getAuthorizedCustomer(
            Long customerId,
            Authentication authentication
    ) {

        if (isCustomer(authentication)) {

            Customer currentCustomer =
                    currentUserService.getCurrentCustomer(
                            authentication
                    );

            if (!currentCustomer.getId().equals(customerId)) {

                throw new IllegalStateException(
                        "You are not authorized to access these service requests."
                );
            }

            return currentCustomer;
        }

        return customerRepository.findById(customerId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Customer not found: " + customerId
                        )
                );
    }

    private ServiceRequest findRequest(
            Long requestId
    ) {

        return serviceRequestRepository
                .findById(requestId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Service request not found: "
                                        + requestId
                        )
                );
    }

    private boolean isCustomer(
            Authentication authentication
    ) {

        return authentication.getAuthorities()
                .stream()
                .anyMatch(authority ->
                        authority.getAuthority()
                                .equals(
                                        "ROLE_" +
                                        Role.CUSTOMER.name()
                                )
                );
    }
}