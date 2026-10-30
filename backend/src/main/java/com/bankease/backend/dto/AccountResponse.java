package com.bankease.backend.dto;

import com.bankease.backend.entity.Account;
import com.bankease.backend.entity.AccountStatus;
import com.bankease.backend.entity.AccountType;

import java.math.BigDecimal;

public class AccountResponse {

    private Long id;
    private String accountNumber;
    private AccountType accountType;
    private BigDecimal balance;
    private AccountStatus status;
    private String customerName;

    public AccountResponse() {
    }

    public static AccountResponse fromEntity(Account account) {

        AccountResponse response = new AccountResponse();

        response.id = account.getId();
        response.accountNumber = account.getAccountNumber();
        response.accountType = account.getAccountType();
        response.balance = account.getBalance();
        response.status = account.getStatus();

        if (account.getCustomer() != null) {
            response.customerName =
                    account.getCustomer().getFullName();
        }

        return response;
    }

    public Long getId() {
        return id;
    }

    public String getAccountNumber() {
        return accountNumber;
    }

    public AccountType getAccountType() {
        return accountType;
    }

    public BigDecimal getBalance() {
        return balance;
    }

    public AccountStatus getStatus() {
        return status;
    }

    public String getCustomerName() {
        return customerName;
    }
}