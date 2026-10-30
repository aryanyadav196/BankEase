package com.bankease.backend.controller;

import com.bankease.backend.dto.AdminOverviewResponse;
import com.bankease.backend.dto.AccountResponse;
import com.bankease.backend.dto.AuditLogResponse;
import com.bankease.backend.dto.AutomationRuleResponse;
import com.bankease.backend.dto.TransactionResponse;
import com.bankease.backend.dto.PendingUserResponse;
import com.bankease.backend.dto.UserActionResponse;
import com.bankease.backend.entity.Role;
import com.bankease.backend.entity.User;
import com.bankease.backend.repository.AccountRepository;
import com.bankease.backend.repository.AuditLogRepository;
import com.bankease.backend.repository.AutomationRuleRepository;
import com.bankease.backend.repository.TransactionRepository;
import com.bankease.backend.repository.UserRepository;
import com.bankease.backend.service.AdminOverviewService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final AdminOverviewService adminOverviewService;
    private final AccountRepository accountRepository;
    private final TransactionRepository transactionRepository;
    private final AutomationRuleRepository automationRuleRepository;
    private final AuditLogRepository auditLogRepository;
    private final UserRepository userRepository;

    public AdminController(
            AdminOverviewService adminOverviewService,
            AccountRepository accountRepository,
            TransactionRepository transactionRepository,
            AutomationRuleRepository automationRuleRepository,
            AuditLogRepository auditLogRepository,
            UserRepository userRepository
    ) {
        this.adminOverviewService =
                adminOverviewService;
        this.accountRepository = accountRepository;
        this.transactionRepository = transactionRepository;
        this.automationRuleRepository = automationRuleRepository;
        this.auditLogRepository = auditLogRepository;
        this.userRepository = userRepository;
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/overview")
    public ResponseEntity<AdminOverviewResponse> getOverview() {

        AdminOverviewResponse response =
                adminOverviewService.getOverview();

        return ResponseEntity.ok(response);
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/accounts")
    public ResponseEntity<List<AccountResponse>> getAccounts() {

        return ResponseEntity.ok(
                accountRepository.findAll()
                        .stream()
                        .map(AccountResponse::fromEntity)
                        .toList()
        );
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/transactions")
    public ResponseEntity<List<TransactionResponse>> getTransactions() {

        return ResponseEntity.ok(
                transactionRepository.findAll()
                        .stream()
                        .map(TransactionResponse::fromEntity)
                        .toList()
        );
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/automation-rules")
    public ResponseEntity<List<AutomationRuleResponse>> getAutomationRules() {

        return ResponseEntity.ok(
                automationRuleRepository.findAll()
                        .stream()
                        .map(AutomationRuleResponse::fromEntity)
                        .toList()
        );
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/audit-logs")
    public ResponseEntity<List<AuditLogResponse>> getAuditLogs() {

        return ResponseEntity.ok(
                auditLogRepository.findAllByOrderByCreatedAtDesc()
                        .stream()
                        .map(AuditLogResponse::fromEntity)
                        .toList()
        );
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/pending-users")
    public ResponseEntity<List<PendingUserResponse>> getPendingUsers() {

        return ResponseEntity.ok(
                userRepository.findByActiveFalseAndRoleIn(
                                List.of(Role.EMPLOYEE, Role.ADMIN)
                        )
                        .stream()
                        .map(PendingUserResponse::fromEntity)
                        .toList()
        );
    }

    @PreAuthorize("hasRole('ADMIN')")
    @PatchMapping("/pending-users/{userId}/approve")
    public ResponseEntity<UserActionResponse> approveUser(
            @PathVariable Long userId
    ) {

        User user = findPendingStaffUser(userId);
        user.setActive(true);
        userRepository.save(user);

        return ResponseEntity.ok(
                new UserActionResponse(
                        "User approved successfully."
                )
        );
    }

    @PreAuthorize("hasRole('ADMIN')")
    @DeleteMapping("/pending-users/{userId}")
    public ResponseEntity<UserActionResponse> rejectUser(
            @PathVariable Long userId
    ) {

        User user = findPendingStaffUser(userId);
        userRepository.delete(user);

        return ResponseEntity.ok(
                new UserActionResponse(
                        "Registration request rejected."
                )
        );
    }

    private User findPendingStaffUser(Long userId) {

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Pending registration not found."
                ));

        if (user.isActive()
                || (user.getRole() != Role.EMPLOYEE
                && user.getRole() != Role.ADMIN)) {
            throw new IllegalArgumentException(
                    "Only pending employee or admin registrations can be managed."
            );
        }

        return user;
    }
}
