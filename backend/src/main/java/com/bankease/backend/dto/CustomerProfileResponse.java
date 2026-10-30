package com.bankease.backend.dto;

import com.bankease.backend.entity.Customer;

public class CustomerProfileResponse {

    private Long id;
    private String fullName;
    private String phone;
    private String address;
    private String email;

    public CustomerProfileResponse() {
    }

    public static CustomerProfileResponse fromEntity(
            Customer customer
    ) {

        CustomerProfileResponse response =
                new CustomerProfileResponse();

        response.id = customer.getId();
        response.fullName = customer.getFullName();
        response.phone = customer.getPhone();
        response.address = customer.getAddress();

        if (customer.getUser() != null) {
            response.email =
                    customer.getUser().getEmail();
        }

        return response;
    }

    public Long getId() {
        return id;
    }

    public String getFullName() {
        return fullName;
    }

    public String getPhone() {
        return phone;
    }

    public String getAddress() {
        return address;
    }

    public String getEmail() {
        return email;
    }
}