package com.bankease.backend.service;

import com.bankease.backend.dto.LoginRequest;
import com.bankease.backend.dto.LoginResponse;
import com.bankease.backend.dto.RegisterRequest;
import com.bankease.backend.dto.RegistrationResponse;
import com.bankease.backend.dto.StaffRegistrationRequest;
import com.bankease.backend.entity.Customer;
import com.bankease.backend.entity.Role;
import com.bankease.backend.entity.User;
import com.bankease.backend.repository.CustomerRepository;
import com.bankease.backend.repository.UserRepository;
import com.bankease.backend.security.JwtService;
import com.bankease.backend.security.CustomUserDetailsService;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final CustomUserDetailsService userDetailsService;
    private final JwtService jwtService;
    private final UserRepository userRepository;
    private final CustomerRepository customerRepository;
    private final PasswordEncoder passwordEncoder;

    public AuthService(
            AuthenticationManager authenticationManager,
            CustomUserDetailsService userDetailsService,
            JwtService jwtService,
            UserRepository userRepository,
            CustomerRepository customerRepository,
            PasswordEncoder passwordEncoder
    ) {
        this.authenticationManager = authenticationManager;
        this.userDetailsService = userDetailsService;
        this.jwtService = jwtService;
        this.userRepository = userRepository;
        this.customerRepository = customerRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public RegistrationResponse register(RegisterRequest request) {

        String email = request.getEmail().trim().toLowerCase();

        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException(
                    "An account with this email already exists."
            );
        }

        User user = new User();
        user.setEmail(email);
        user.setPassword(
                passwordEncoder.encode(request.getPassword())
        );
        user.setRole(Role.CUSTOMER);
        user.setActive(true);
        User savedUser = userRepository.save(user);

        Customer customer = new Customer();
        customer.setUser(savedUser);
        customer.setFullName(request.getFullName().trim());
        customer.setPhone(request.getPhone().trim());
        customer.setAddress(
                request.getAddress() == null
                        ? null
                        : request.getAddress().trim()
        );
        customerRepository.save(customer);

        return new RegistrationResponse(
                "Customer account created successfully. Please sign in.",
                savedUser.getEmail(),
                savedUser.getRole().name()
        );
    }

    @Transactional
    public RegistrationResponse registerStaff(
            StaffRegistrationRequest request,
            Role role
    ) {

        String email = request.getEmail().trim().toLowerCase();

        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException(
                    "An account with this email already exists."
            );
        }

        User user = new User();
        user.setEmail(email);
        user.setPassword(
                passwordEncoder.encode(request.getPassword())
        );
        user.setRole(role);
        user.setActive(false);
        userRepository.save(user);

        return new RegistrationResponse(
                "Your registration request has been submitted and requires administrator approval.",
                user.getEmail(),
                user.getRole().name()
        );
    }

    public LoginResponse login(LoginRequest request) {

        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        User user = userRepository
                .findByEmail(request.getEmail())
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "User not found."
                        )
                );

        UserDetails userDetails =
                userDetailsService.loadUserByUsername(
                        request.getEmail()
                );

        String token =
                jwtService.generateToken(userDetails);

        return new LoginResponse(
                token,
                user.getEmail(),
                user.getRole().name()
        );
    }
}
