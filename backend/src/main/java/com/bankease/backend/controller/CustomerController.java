package com.bankease.backend.controller;

import com.bankease.backend.dto.CustomerProfileResponse;
import com.bankease.backend.entity.Customer;
import com.bankease.backend.security.CurrentUserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/customers")
public class CustomerController {

    private final CurrentUserService currentUserService;

    public CustomerController(
            CurrentUserService currentUserService
    ) {
        this.currentUserService =
                currentUserService;
    }

    @PreAuthorize("hasRole('CUSTOMER')")
    @GetMapping("/me")
    public ResponseEntity<CustomerProfileResponse> getMyProfile(
            Authentication authentication
    ) {

        Customer customer =
                currentUserService.getCurrentCustomer(
                        authentication
                );

        return ResponseEntity.ok(
                CustomerProfileResponse.fromEntity(customer)
        );
    }
}