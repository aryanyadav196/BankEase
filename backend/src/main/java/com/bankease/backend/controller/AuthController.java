package com.bankease.backend.controller;

import com.bankease.backend.dto.LoginRequest;
import com.bankease.backend.dto.LoginResponse;
import com.bankease.backend.dto.RegisterRequest;
import com.bankease.backend.dto.RegistrationResponse;
import com.bankease.backend.dto.StaffRegistrationRequest;
import com.bankease.backend.entity.Role;
import com.bankease.backend.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(
            AuthService authService
    ) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(
            @Valid @RequestBody LoginRequest request
    ) {

        LoginResponse response =
                authService.login(request);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    public ResponseEntity<RegistrationResponse> register(
            @Valid @RequestBody RegisterRequest request
    ) {

        RegistrationResponse response =
                authService.register(request);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/register/employee")
    public ResponseEntity<RegistrationResponse> registerEmployee(
            @Valid @RequestBody StaffRegistrationRequest request
    ) {

        return ResponseEntity.ok(
                authService.registerStaff(request, Role.EMPLOYEE)
        );
    }

    @PostMapping("/register/admin")
    public ResponseEntity<RegistrationResponse> registerAdmin(
            @Valid @RequestBody StaffRegistrationRequest request
    ) {

        return ResponseEntity.ok(
                authService.registerStaff(request, Role.ADMIN)
        );
    }
}
