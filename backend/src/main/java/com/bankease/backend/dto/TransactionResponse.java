package com.bankease.backend.dto;

import com.bankease.backend.entity.Transaction;
import com.bankease.backend.entity.TransactionStatus;
import com.bankease.backend.entity.TransactionType;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class TransactionResponse {

    private Long id;
    private String transactionReference;
    private TransactionType type;
    private BigDecimal amount;
    private TransactionStatus status;
    private String sourceAccountNumber;
    private String destinationAccountNumber;
    private LocalDateTime createdAt;
    private String description;

    public TransactionResponse() {
    }

    public static TransactionResponse fromEntity(Transaction transaction) {

        TransactionResponse response = new TransactionResponse();

        response.id = transaction.getId();
        response.transactionReference =
                transaction.getTransactionReference();
        response.type = transaction.getType();
        response.amount = transaction.getAmount();
        response.status = transaction.getStatus();

        if (transaction.getSourceAccount() != null) {
            response.sourceAccountNumber =
                    transaction.getSourceAccount().getAccountNumber();
        }

        if (transaction.getDestinationAccount() != null) {
            response.destinationAccountNumber =
                    transaction.getDestinationAccount().getAccountNumber();
        }

        response.createdAt = transaction.getCreatedAt();
        response.description = transaction.getDescription();

        return response;
    }

    public Long getId() {
        return id;
    }

    public String getTransactionReference() {
        return transactionReference;
    }

    public TransactionType getType() {
        return type;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public TransactionStatus getStatus() {
        return status;
    }

    public String getSourceAccountNumber() {
        return sourceAccountNumber;
    }

    public String getDestinationAccountNumber() {
        return destinationAccountNumber;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public String getDescription() {
        return description;
    }
}