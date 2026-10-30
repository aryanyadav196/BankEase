package com.bankease.backend.controller;

import com.bankease.backend.dto.AccountResponse;
import com.bankease.backend.dto.CreateAccountRequest;
import com.bankease.backend.service.AccountService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/accounts")
public class AccountController {

    private final AccountService accountService;

    public AccountController(
            AccountService accountService
    ) {
        this.accountService = accountService;
    }

    @PreAuthorize("hasAnyRole('EMPLOYEE', 'ADMIN')")
    @PostMapping
    public ResponseEntity<AccountResponse> createAccount(
            @RequestParam Long customerId,
            @Valid @RequestBody CreateAccountRequest request
    ) {

        AccountResponse response =
                accountService.createAccount(
                        customerId,
                        request.getAccountType()
                );

        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasAnyRole('CUSTOMER', 'EMPLOYEE', 'ADMIN')")
    @GetMapping("/{accountNumber}")
    public ResponseEntity<AccountResponse> getAccount(
            @PathVariable String accountNumber,
            Authentication authentication
    ) {

        AccountResponse response =
                accountService.getAccountByNumber(
                        accountNumber,
                        authentication
                );

        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasAnyRole('CUSTOMER', 'EMPLOYEE', 'ADMIN')")
    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<AccountResponse>> getCustomerAccounts(
            @PathVariable Long customerId,
            Authentication authentication
    ) {

        List<AccountResponse> accounts =
                accountService.getAccountsByCustomerId(
                        customerId,
                        authentication
                );

        return ResponseEntity.ok(accounts);
    }

    @PreAuthorize("hasAnyRole('EMPLOYEE', 'ADMIN')")
    @PatchMapping("/{accountNumber}/block")
    public ResponseEntity<AccountResponse> blockAccount(
            @PathVariable String accountNumber
    ) {

        AccountResponse response =
                accountService.blockAccount(
                        accountNumber
                );

        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasAnyRole('EMPLOYEE', 'ADMIN')")
    @PatchMapping("/{accountNumber}/close")
    public ResponseEntity<AccountResponse> closeAccount(
            @PathVariable String accountNumber
    ) {

        AccountResponse response =
                accountService.closeAccount(
                        accountNumber
                );

        return ResponseEntity.ok(response);
    }
}