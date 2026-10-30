package com.bankease.backend.service;

import com.bankease.backend.dto.AccountResponse;
import com.bankease.backend.entity.Account;
import com.bankease.backend.entity.AccountStatus;
import com.bankease.backend.entity.AccountType;
import com.bankease.backend.entity.Customer;
import com.bankease.backend.entity.Role;
import com.bankease.backend.repository.AccountRepository;
import com.bankease.backend.repository.CustomerRepository;
import com.bankease.backend.security.CurrentUserService;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Service
public class AccountService {

    private final AccountRepository accountRepository;
    private final CustomerRepository customerRepository;
    private final CurrentUserService currentUserService;

    public AccountService(
            AccountRepository accountRepository,
            CustomerRepository customerRepository,
            CurrentUserService currentUserService
    ) {
        this.accountRepository = accountRepository;
        this.customerRepository = customerRepository;
        this.currentUserService = currentUserService;
    }

    @Transactional
    public AccountResponse createAccount(
            Long customerId,
            AccountType accountType
    ) {

        Customer customer =
                customerRepository.findById(customerId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Customer not found: " + customerId
                                )
                        );

        Account account = new Account();

        account.setAccountNumber(
                generateAccountNumber()
        );

        account.setAccountType(accountType);
        account.setBalance(BigDecimal.ZERO);
        account.setStatus(AccountStatus.ACTIVE);
        account.setCustomer(customer);

        Account savedAccount =
                accountRepository.save(account);

        return AccountResponse.fromEntity(savedAccount);
    }

    public AccountResponse getAccountByNumber(
            String accountNumber,
            Authentication authentication
    ) {

        Account account;

        if (isCustomer(authentication)) {

            Customer currentCustomer =
                    currentUserService.getCurrentCustomer(
                            authentication
                    );

            account =
                    accountRepository
                            .findByAccountNumberAndCustomerId(
                                    accountNumber,
                                    currentCustomer.getId()
                            )
                            .orElseThrow(() ->
                                    new IllegalArgumentException(
                                            "Account not found."
                                    )
                            );

        } else {

            account =
                    accountRepository
                            .findByAccountNumber(accountNumber)
                            .orElseThrow(() ->
                                    new IllegalArgumentException(
                                            "Account not found: "
                                                    + accountNumber
                                    )
                            );
        }

        return AccountResponse.fromEntity(account);
    }

    public List<AccountResponse> getAccountsByCustomerId(
            Long customerId,
            Authentication authentication
    ) {

        if (isCustomer(authentication)) {

            Customer currentCustomer =
                    currentUserService.getCurrentCustomer(
                            authentication
                    );

            if (!currentCustomer.getId().equals(customerId)) {

                throw new IllegalStateException(
                        "You are not authorized to access these accounts."
                );
            }
        }

        return accountRepository
                .findByCustomerId(customerId)
                .stream()
                .map(AccountResponse::fromEntity)
                .toList();
    }

    @Transactional
    public AccountResponse blockAccount(
            String accountNumber
    ) {

        Account account =
                accountRepository
                        .findByAccountNumber(accountNumber)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Account not found: "
                                                + accountNumber
                                )
                        );

        if (account.getStatus() == AccountStatus.CLOSED) {

            throw new IllegalStateException(
                    "Closed account cannot be blocked."
            );
        }

        if (account.getStatus() == AccountStatus.BLOCKED) {

            throw new IllegalStateException(
                    "Account is already blocked."
            );
        }

        account.setStatus(AccountStatus.BLOCKED);

        Account savedAccount =
                accountRepository.save(account);

        return AccountResponse.fromEntity(savedAccount);
    }

    @Transactional
    public AccountResponse closeAccount(
            String accountNumber
    ) {

        Account account =
                accountRepository
                        .findByAccountNumber(accountNumber)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Account not found: "
                                                + accountNumber
                                )
                        );

        if (account.getStatus() == AccountStatus.CLOSED) {

            throw new IllegalStateException(
                    "Account is already closed."
            );
        }

        if (account.getBalance()
                .compareTo(BigDecimal.ZERO) != 0) {

            throw new IllegalStateException(
                    "Account cannot be closed because the balance is not zero."
            );
        }

        account.setStatus(AccountStatus.CLOSED);

        Account savedAccount =
                accountRepository.save(account);

        return AccountResponse.fromEntity(savedAccount);
    }

    private boolean isCustomer(
            Authentication authentication
    ) {

        return authentication.getAuthorities()
                .stream()
                .anyMatch(authority ->
                        authority.getAuthority()
                                .equals("ROLE_" + Role.CUSTOMER.name())
                );
    }

    private String generateAccountNumber() {

        String accountNumber;

        do {

            accountNumber =
                    "100000"
                            + UUID.randomUUID()
                            .toString()
                            .replace("-", "")
                            .substring(0, 6)
                            .toUpperCase();

        } while (accountRepository
                .findByAccountNumber(accountNumber)
                .isPresent());

        return accountNumber;
    }
}