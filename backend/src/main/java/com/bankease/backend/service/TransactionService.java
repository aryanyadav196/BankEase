package com.bankease.backend.service;

import com.bankease.backend.entity.Account;
import com.bankease.backend.entity.Role;
import com.bankease.backend.entity.Transaction;
import com.bankease.backend.entity.TransactionStatus;
import com.bankease.backend.entity.TransactionType;
import com.bankease.backend.entity.User;
import com.bankease.backend.repository.AccountRepository;
import com.bankease.backend.repository.TransactionRepository;
import com.bankease.backend.security.CurrentUserService;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
public class TransactionService {

    private final AccountRepository accountRepository;
    private final TransactionRepository transactionRepository;
    private final RuleEvaluationService ruleEvaluationService;
    private final RuleAutomationService ruleAutomationService;
    private final CurrentUserService currentUserService;

    public TransactionService(
            AccountRepository accountRepository,
            TransactionRepository transactionRepository,
            RuleEvaluationService ruleEvaluationService,
            RuleAutomationService ruleAutomationService,
            CurrentUserService currentUserService
    ) {
        this.accountRepository = accountRepository;
        this.transactionRepository = transactionRepository;
        this.ruleEvaluationService = ruleEvaluationService;
        this.ruleAutomationService = ruleAutomationService;
        this.currentUserService = currentUserService;
    }

    @Transactional
    public Transaction deposit(
            String accountNumber,
            BigDecimal amount,
            Authentication authentication
    ) {

        Account account =
                findAuthorizedAccount(
                        accountNumber,
                        authentication
                );

        RuleEvaluationResult ruleResult =
                ruleEvaluationService.validateDeposit(
                        account,
                        amount
                );

        if (!ruleResult.isAllowed()) {

            Transaction rejectedTransaction =
                    createRejectedTransaction(
                            TransactionType.DEPOSIT,
                            amount,
                            account,
                            null,
                            ruleResult.getMessage()
                    );

            recordRuleResult(
                    ruleResult,
                    authentication
            );

            return rejectedTransaction;
        }

        account.setBalance(
                account.getBalance().add(amount)
        );

        accountRepository.save(account);

        Transaction transaction =
                createTransaction(
                        TransactionType.DEPOSIT,
                        amount,
                        account,
                        null,
                        TransactionStatus.COMPLETED,
                        "Cash deposit completed."
                );

        Transaction savedTransaction =
                transactionRepository.save(transaction);

        recordRuleResult(
                ruleResult,
                authentication
        );

        return savedTransaction;
    }

    @Transactional
    public Transaction withdraw(
            String accountNumber,
            BigDecimal amount,
            Authentication authentication
    ) {

        Account account =
                findAuthorizedAccount(
                        accountNumber,
                        authentication
                );

        RuleEvaluationResult ruleResult =
                ruleEvaluationService.validateWithdrawal(
                        account,
                        amount
                );

        if (!ruleResult.isAllowed()) {

            Transaction rejectedTransaction =
                    createRejectedTransaction(
                            TransactionType.WITHDRAWAL,
                            amount,
                            account,
                            null,
                            ruleResult.getMessage()
                    );

            recordRuleResult(
                    ruleResult,
                    authentication
            );

            return rejectedTransaction;
        }

        account.setBalance(
                account.getBalance().subtract(amount)
        );

        accountRepository.save(account);

        Transaction transaction =
                createTransaction(
                        TransactionType.WITHDRAWAL,
                        amount,
                        account,
                        null,
                        TransactionStatus.COMPLETED,
                        "Withdrawal completed."
                );

        Transaction savedTransaction =
                transactionRepository.save(transaction);

        recordRuleResult(
                ruleResult,
                authentication
        );

        return savedTransaction;
    }

    @Transactional
    public Transaction transfer(
            String sourceAccountNumber,
            String destinationAccountNumber,
            BigDecimal amount,
            Authentication authentication
    ) {

        Account sourceAccount =
                findAuthorizedAccount(
                        sourceAccountNumber,
                        authentication
                );

        Account destinationAccount =
                findAccount(destinationAccountNumber);

        RuleEvaluationResult ruleResult =
                ruleEvaluationService.validateTransfer(
                        sourceAccount,
                        destinationAccount,
                        amount
                );

        if (!ruleResult.isAllowed()) {

            Transaction rejectedTransaction =
                    createRejectedTransaction(
                            TransactionType.TRANSFER,
                            amount,
                            sourceAccount,
                            destinationAccount,
                            ruleResult.getMessage()
                    );

            recordRuleResult(
                    ruleResult,
                    authentication
            );

            return rejectedTransaction;
        }

        sourceAccount.setBalance(
                sourceAccount.getBalance().subtract(amount)
        );

        destinationAccount.setBalance(
                destinationAccount.getBalance().add(amount)
        );

        accountRepository.save(sourceAccount);
        accountRepository.save(destinationAccount);

        Transaction transaction =
                createTransaction(
                        TransactionType.TRANSFER,
                        amount,
                        sourceAccount,
                        destinationAccount,
                        TransactionStatus.COMPLETED,
                        "Fund transfer completed."
                );

        Transaction savedTransaction =
                transactionRepository.save(transaction);

        recordRuleResult(
                ruleResult,
                authentication
        );

        return savedTransaction;
    }

    public java.util.List<Transaction> getMyTransactions(
                Authentication authentication
        ) {

        Long customerId =
                currentUserService
                        .getCurrentCustomer(authentication)
                        .getId();

        return transactionRepository
                .findCustomerTransactionsByAccountOwnership(
                        customerId,
                        customerId
                );
        }

        public Transaction getMyTransactionById(
                Long transactionId,
                Authentication authentication
        ) {

        Long customerId =
                currentUserService
                        .getCurrentCustomer(authentication)
                        .getId();

        return transactionRepository
                .findByIdAndSourceAccountCustomerId(
                        transactionId,
                        customerId
                )
                .or(() ->
                        transactionRepository
                                .findByIdAndDestinationAccountCustomerId(
                                        transactionId,
                                        customerId
                                )
                )
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Transaction not found."
                        )
                );
        }

    private Account findAuthorizedAccount(
            String accountNumber,
            Authentication authentication
    ) {

        if (isCustomer(authentication)) {

            Long customerId =
                    currentUserService
                            .getCurrentCustomer(authentication)
                            .getId();

            return accountRepository
                    .findByAccountNumberAndCustomerId(
                            accountNumber,
                            customerId
                    )
                    .orElseThrow(() ->
                            new IllegalArgumentException(
                                    "Account not found."
                            )
                    );
        }

        return findAccount(accountNumber);
    }

    private Account findAccount(
            String accountNumber
    ) {

        return accountRepository
                .findByAccountNumber(accountNumber)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Account not found: "
                                        + accountNumber
                        )
                );
    }

    private boolean isCustomer(
            Authentication authentication
    ) {

        return authentication.getAuthorities()
                .stream()
                .anyMatch(authority ->
                        authority.getAuthority()
                                .equals(
                                        "ROLE_" +
                                        Role.CUSTOMER.name()
                                )
                );
    }

    private void recordRuleResult(
            RuleEvaluationResult ruleResult,
            Authentication authentication
    ) {

        User user = null;

        if (authentication != null
                && authentication.isAuthenticated()) {

            user =
                    currentUserService.getCurrentUser(
                            authentication
                    );
        }

        ruleAutomationService.recordRuleResult(
                ruleResult,
                user
        );
    }

    private Transaction createTransaction(
            TransactionType type,
            BigDecimal amount,
            Account sourceAccount,
            Account destinationAccount,
            TransactionStatus status,
            String description
    ) {

        Transaction transaction =
                new Transaction();

        transaction.setTransactionReference(
                generateTransactionReference()
        );

        transaction.setType(type);

        transaction.setAmount(
                amount == null
                        ? BigDecimal.ZERO
                        : amount
        );

        transaction.setStatus(status);

        transaction.setSourceAccount(
                sourceAccount
        );

        transaction.setDestinationAccount(
                destinationAccount
        );

        transaction.setCreatedAt(
                LocalDateTime.now()
        );

        transaction.setDescription(
                description
        );

        return transaction;
    }

    private Transaction createRejectedTransaction(
            TransactionType type,
            BigDecimal amount,
            Account sourceAccount,
            Account destinationAccount,
            String description
    ) {

        Transaction transaction =
                createTransaction(
                        type,
                        amount,
                        sourceAccount,
                        destinationAccount,
                        TransactionStatus.REJECTED,
                        description
                );

        return transactionRepository.save(
                transaction
        );
    }

    private String generateTransactionReference() {

        return "TXN-" +
                UUID.randomUUID()
                        .toString()
                        .replace("-", "")
                        .substring(0, 20)
                        .toUpperCase();
    }
}
