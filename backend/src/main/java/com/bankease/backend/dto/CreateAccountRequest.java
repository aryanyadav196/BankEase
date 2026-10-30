package com.bankease.backend.dto;

import com.bankease.backend.entity.AccountType;
import jakarta.validation.constraints.NotNull;

public class CreateAccountRequest {

    @NotNull
    private AccountType accountType;

    public CreateAccountRequest() {
    }

    public AccountType getAccountType() {
        return accountType;
    }

    public void setAccountType(AccountType accountType) {
        this.accountType = accountType;
    }
}