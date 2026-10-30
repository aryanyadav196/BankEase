package com.bankease.backend.controller;

import com.bankease.backend.dto.DepositRequest;
import com.bankease.backend.dto.TransactionResponse;
import com.bankease.backend.dto.TransferRequest;
import com.bankease.backend.dto.WithdrawalRequest;
import com.bankease.backend.entity.Transaction;
import com.bankease.backend.service.TransactionService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/transactions")
public class TransactionController {

    private final TransactionService transactionService;

    public TransactionController(
            TransactionService transactionService
    ) {
        this.transactionService = transactionService;
    }

    @PreAuthorize("hasAnyRole('CUSTOMER', 'EMPLOYEE', 'ADMIN')")
    @PostMapping("/deposit")
    public ResponseEntity<TransactionResponse> deposit(
            @Valid @RequestBody DepositRequest request,
            Authentication authentication
    ) {

        Transaction transaction =
                transactionService.deposit(
                        request.getAccountNumber(),
                        request.getAmount(),
                        authentication
                );

        return ResponseEntity.ok(
                TransactionResponse.fromEntity(transaction)
        );
    }

    @PreAuthorize("hasAnyRole('CUSTOMER', 'EMPLOYEE', 'ADMIN')")
    @PostMapping("/withdraw")
    public ResponseEntity<TransactionResponse> withdraw(
            @Valid @RequestBody WithdrawalRequest request,
            Authentication authentication
    ) {

        Transaction transaction =
                transactionService.withdraw(
                        request.getAccountNumber(),
                        request.getAmount(),
                        authentication
                );

        return ResponseEntity.ok(
                TransactionResponse.fromEntity(transaction)
        );
    }

    @PreAuthorize("hasAnyRole('CUSTOMER', 'EMPLOYEE', 'ADMIN')")
    @PostMapping("/transfer")
    public ResponseEntity<TransactionResponse> transfer(
            @Valid @RequestBody TransferRequest request,
            Authentication authentication
    ) {

        Transaction transaction =
                transactionService.transfer(
                        request.getSourceAccountNumber(),
                        request.getDestinationAccountNumber(),
                        request.getAmount(),
                        authentication
                );

        return ResponseEntity.ok(
                TransactionResponse.fromEntity(transaction)
        );
    }

    @PreAuthorize("hasAnyRole('CUSTOMER', 'EMPLOYEE', 'ADMIN')")
        @GetMapping("/my")
        public ResponseEntity<List<TransactionResponse>> getMyTransactions(
                Authentication authentication
        ) {

        List<TransactionResponse> transactions =
                transactionService
                        .getMyTransactions(authentication)
                        .stream()
                        .map(TransactionResponse::fromEntity)
                        .toList();

        return ResponseEntity.ok(transactions);
        }

        @PreAuthorize("hasAnyRole('CUSTOMER', 'EMPLOYEE', 'ADMIN')")
        @GetMapping("/my/{transactionId}")
        public ResponseEntity<TransactionResponse> getMyTransaction(
                @PathVariable Long transactionId,
                Authentication authentication
        ) {

        Transaction transaction =
                transactionService.getMyTransactionById(
                        transactionId,
                        authentication
                );

        return ResponseEntity.ok(
                TransactionResponse.fromEntity(transaction)
        );
        }
}