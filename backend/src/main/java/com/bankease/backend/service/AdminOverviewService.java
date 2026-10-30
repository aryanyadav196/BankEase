package com.bankease.backend.service;

import com.bankease.backend.dto.AdminOverviewResponse;
import com.bankease.backend.entity.AccountStatus;
import com.bankease.backend.entity.ServiceRequestStatus;
import com.bankease.backend.entity.TransactionStatus;
import com.bankease.backend.repository.AccountRepository;
import com.bankease.backend.repository.AuditLogRepository;
import com.bankease.backend.repository.AutomationRuleRepository;
import com.bankease.backend.repository.CustomerRepository;
import com.bankease.backend.repository.ServiceRequestRepository;
import com.bankease.backend.repository.TransactionRepository;
import com.bankease.backend.repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
public class AdminOverviewService {

    private final UserRepository userRepository;
    private final CustomerRepository customerRepository;
    private final AccountRepository accountRepository;
    private final TransactionRepository transactionRepository;
    private final ServiceRequestRepository serviceRequestRepository;
    private final AuditLogRepository auditLogRepository;
    private final AutomationRuleRepository automationRuleRepository;

    public AdminOverviewService(
            UserRepository userRepository,
            CustomerRepository customerRepository,
            AccountRepository accountRepository,
            TransactionRepository transactionRepository,
            ServiceRequestRepository serviceRequestRepository,
            AuditLogRepository auditLogRepository,
            AutomationRuleRepository automationRuleRepository
    ) {
        this.userRepository = userRepository;
        this.customerRepository = customerRepository;
        this.accountRepository = accountRepository;
        this.transactionRepository = transactionRepository;
        this.serviceRequestRepository = serviceRequestRepository;
        this.auditLogRepository = auditLogRepository;
        this.automationRuleRepository = automationRuleRepository;
    }

    public AdminOverviewResponse getOverview() {

        AdminOverviewResponse response =
                new AdminOverviewResponse();

        response.setTotalUsers(
                userRepository.count()
        );

        response.setTotalCustomers(
                customerRepository.count()
        );

        response.setTotalAccounts(
                accountRepository.count()
        );

        response.setTotalTransactions(
                transactionRepository.count()
        );

        response.setPendingServiceRequests(
                serviceRequestRepository
                        .findByStatus(
                                ServiceRequestStatus.PENDING
                        )
                        .size()
        );

        response.setBlockedAccounts(
                accountRepository.countByStatus(
                        AccountStatus.BLOCKED
                )
        );

        response.setRejectedTransactions(
                transactionRepository.countByStatus(
                        TransactionStatus.REJECTED
                )
        );

        response.setTotalAuditLogs(
                auditLogRepository.count()
        );

        response.setActiveAutomationRules(
                automationRuleRepository
                        .countByActiveTrue()
        );

        return response;
    }
}