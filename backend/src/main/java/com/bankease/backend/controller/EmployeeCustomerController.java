package com.bankease.backend.controller;

import com.bankease.backend.dto.CustomerResponse;
import com.bankease.backend.repository.CustomerRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/employee/customers")
public class EmployeeCustomerController {

    private final CustomerRepository customerRepository;

    public EmployeeCustomerController(
            CustomerRepository customerRepository
    ) {
        this.customerRepository = customerRepository;
    }

    @PreAuthorize("hasAnyRole('EMPLOYEE', 'ADMIN')")
    @GetMapping
    public ResponseEntity<List<CustomerResponse>> getCustomers() {

        List<CustomerResponse> customers =
                customerRepository.findAll()
                        .stream()
                        .map(CustomerResponse::fromEntity)
                        .toList();

        return ResponseEntity.ok(customers);
    }
}