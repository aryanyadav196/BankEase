package com.bankease.backend.repository;

import com.bankease.backend.entity.Account;
import com.bankease.backend.entity.AccountStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AccountRepository
        extends JpaRepository<Account, Long> {

    Optional<Account> findByAccountNumber(
            String accountNumber
    );

    List<Account> findByCustomerId(
            Long customerId
    );

    Optional<Account> findByAccountNumberAndCustomerId(
            String accountNumber,
            Long customerId
    );

    long countByStatus(AccountStatus status);
}