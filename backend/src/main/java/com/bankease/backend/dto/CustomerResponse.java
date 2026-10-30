package com.bankease.backend.dto;

import com.bankease.backend.entity.Customer;

public class CustomerResponse {

    private Long id;
    private String fullName;
    private String email;
    private String phone;
    private String address;

    public CustomerResponse() {
    }

    public CustomerResponse(
            Long id,
            String fullName,
            String email,
            String phone,
            String address
    ) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.address = address;
    }

    public static CustomerResponse fromEntity(
            Customer customer
    ) {

        return new CustomerResponse(
                customer.getId(),
                customer.getFullName(),
                customer.getUser().getEmail(),
                customer.getPhone(),
                customer.getAddress()
        );
    }

    public Long getId() {
        return id;
    }

    public String getFullName() {
        return fullName;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public String getAddress() {
        return address;
    }
}