package com.bankease.backend.security;

import com.bankease.backend.entity.Customer;
import com.bankease.backend.entity.User;
import com.bankease.backend.repository.CustomerRepository;
import com.bankease.backend.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

@Service
public class CurrentUserService {

    private final UserRepository userRepository;
    private final CustomerRepository customerRepository;

    public CurrentUserService(
            UserRepository userRepository,
            CustomerRepository customerRepository
    ) {
        this.userRepository = userRepository;
        this.customerRepository = customerRepository;
    }

    public User getCurrentUser(
            Authentication authentication
    ) {

        if (authentication == null
                || !authentication.isAuthenticated()) {

            throw new IllegalStateException(
                    "User is not authenticated."
            );
        }

        String email = authentication.getName();

        return userRepository.findByEmail(email)
                .orElseThrow(() ->
                        new IllegalStateException(
                                "Authenticated user not found."
                        )
                );
    }

    public Customer getCurrentCustomer(
            Authentication authentication
    ) {

        User user = getCurrentUser(authentication);

        return customerRepository.findByUserId(user.getId())
                .orElseThrow(() ->
                        new IllegalStateException(
                                "Customer profile not found."
                        )
                );
    }
}