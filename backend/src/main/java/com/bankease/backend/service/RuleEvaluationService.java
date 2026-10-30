package com.bankease.backend.service;

import com.bankease.backend.entity.Account;
import com.bankease.backend.entity.AccountStatus;
import com.bankease.backend.entity.AutomationRuleType;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
public class RuleEvaluationService {

    public RuleEvaluationResult validateDeposit(
            Account account,
            BigDecimal amount
    ) {

        RuleEvaluationResult amountResult = validateAmount(amount);

        if (!amountResult.isAllowed()) {
            return amountResult;
        }

        return validateAccountStatus(account);
    }

    public RuleEvaluationResult validateWithdrawal(
            Account account,
            BigDecimal amount
    ) {

        RuleEvaluationResult amountResult = validateAmount(amount);

        if (!amountResult.isAllowed()) {
            return amountResult;
        }

        RuleEvaluationResult accountResult =
                validateAccountStatus(account);

        if (!accountResult.isAllowed()) {
            return accountResult;
        }

        if (amount.compareTo(account.getBalance()) > 0) {
            return new RuleEvaluationResult(
                    false,
                    AutomationRuleType.INSUFFICIENT_BALANCE,
                    "Transaction rejected because the account balance is insufficient."
            );
        }

        return successfulResult();
    }

    public RuleEvaluationResult validateTransfer(
            Account sourceAccount,
            Account destinationAccount,
            BigDecimal amount
    ) {

        RuleEvaluationResult amountResult = validateAmount(amount);

        if (!amountResult.isAllowed()) {
            return amountResult;
        }

        RuleEvaluationResult sourceResult =
                validateAccountStatus(sourceAccount);

        if (!sourceResult.isAllowed()) {
            return sourceResult;
        }

        RuleEvaluationResult destinationResult =
                validateAccountStatus(destinationAccount);

        if (!destinationResult.isAllowed()) {
            return destinationResult;
        }

        if (sourceAccount.getId().equals(destinationAccount.getId())) {
            return new RuleEvaluationResult(
                    false,
                    AutomationRuleType.INVALID_AMOUNT,
                    "Source and destination accounts must be different."
            );
        }

        if (amount.compareTo(sourceAccount.getBalance()) > 0) {
            return new RuleEvaluationResult(
                    false,
                    AutomationRuleType.INSUFFICIENT_BALANCE,
                    "Transfer rejected because the source account balance is insufficient."
            );
        }

        return successfulResult();
    }

    private RuleEvaluationResult validateAmount(BigDecimal amount) {

        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return new RuleEvaluationResult(
                    false,
                    AutomationRuleType.INVALID_AMOUNT,
                    "Transaction amount must be greater than zero."
            );
        }

        return successfulResult();
    }

    private RuleEvaluationResult validateAccountStatus(Account account) {

        if (account.getStatus() == AccountStatus.BLOCKED) {
            return new RuleEvaluationResult(
                    false,
                    AutomationRuleType.BLOCKED_ACCOUNT,
                    "Transaction rejected because the account is blocked."
            );
        }

        if (account.getStatus() == AccountStatus.CLOSED) {
            return new RuleEvaluationResult(
                    false,
                    AutomationRuleType.CLOSED_ACCOUNT,
                    "Transaction rejected because the account is closed."
            );
        }

        return successfulResult();
    }

    private RuleEvaluationResult successfulResult() {

        return new RuleEvaluationResult(
                true,
                AutomationRuleType.SUCCESSFUL_TRANSACTION,
                "All transaction validation rules passed."
        );
    }
}