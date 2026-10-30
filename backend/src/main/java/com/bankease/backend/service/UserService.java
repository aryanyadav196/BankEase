package com.bankease.backend.service;

import com.bankease.backend.entity.Role;
import com.bankease.backend.entity.User;
import com.bankease.backend.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public User createUser(
            String email,
            String password,
            Role role
    ) {

        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException(
                    "User already exists: " + email
            );
        }

        User user = new User();

        user.setEmail(email);
        user.setPassword(
                passwordEncoder.encode(password)
        );
        user.setRole(role);
        user.setActive(true);

        return userRepository.save(user);
    }
}