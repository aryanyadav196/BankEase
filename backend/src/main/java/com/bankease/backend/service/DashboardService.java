package com.bankease.backend.service;

import com.bankease.backend.dto.DashboardResponse;
import com.bankease.backend.entity.AccountStatus;
import com.bankease.backend.entity.ServiceRequestPriority;
import com.bankease.backend.entity.ServiceRequestStatus;
import com.bankease.backend.entity.TransactionStatus;
import com.bankease.backend.repository.AccountRepository;
import com.bankease.backend.repository.CustomerRepository;
import com.bankease.backend.repository.ServiceRequestRepository;
import com.bankease.backend.repository.TransactionRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class DashboardService {

    private final CustomerRepository customerRepository;
    private final AccountRepository accountRepository;
    private final TransactionRepository transactionRepository;
    private final ServiceRequestRepository serviceRequestRepository;

    public DashboardService(
            CustomerRepository customerRepository,
            AccountRepository accountRepository,
            TransactionRepository transactionRepository,
            ServiceRequestRepository serviceRequestRepository
    ) {
        this.customerRepository = customerRepository;
        this.accountRepository = accountRepository;
        this.transactionRepository = transactionRepository;
        this.serviceRequestRepository = serviceRequestRepository;
    }

    public DashboardResponse getDashboard() {

        DashboardResponse response =
                new DashboardResponse();

        response.setTotalCustomers(
                customerRepository.count()
        );

        response.setTotalAccounts(
                accountRepository.count()
        );

        response.setActiveAccounts(
                accountRepository.countByStatus(
                        AccountStatus.ACTIVE
                )
        );

        response.setBlockedAccounts(
                accountRepository.countByStatus(
                        AccountStatus.BLOCKED
                )
        );

        response.setClosedAccounts(
                accountRepository.countByStatus(
                        AccountStatus.CLOSED
                )
        );

        response.setTotalTransactions(
                transactionRepository.count()
        );

        response.setCompletedTransactions(
                transactionRepository.countByStatus(
                        TransactionStatus.COMPLETED
                )
        );

        response.setRejectedTransactions(
                transactionRepository.countByStatus(
                        TransactionStatus.REJECTED
                )
        );

        response.setPendingServiceRequests(
                serviceRequestRepository
                        .findByStatus(
                                ServiceRequestStatus.PENDING
                        )
                        .size()
        );

        response.setHighPriorityRequests(
                serviceRequestRepository
                        .findByPriorityAndStatus(
                                ServiceRequestPriority.HIGH,
                                ServiceRequestStatus.PENDING
                        )
                        .size()
        );

        LocalDateTime overdueTime =
                LocalDateTime.now().minusHours(48);

        response.setOverdueServiceRequests(
                serviceRequestRepository
                        .findByStatusAndCreatedAtBefore(
                                ServiceRequestStatus.PENDING,
                                overdueTime
                        )
                        .size()
        );

        return response;
    }
}