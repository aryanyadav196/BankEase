package com.bankease.backend.repository;

import com.bankease.backend.entity.Transaction;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface TransactionRepository
        extends JpaRepository<Transaction, Long> {

    Optional<Transaction> findByTransactionReference(
            String transactionReference
    );

    @Query("""
            select transaction
            from Transaction transaction
            where transaction.sourceAccount.customer.id = :sourceCustomerId
               or transaction.destinationAccount.customer.id = :destinationCustomerId
            """)
    List<Transaction> findCustomerTransactionsByAccountOwnership(
            @Param("sourceCustomerId")
            Long sourceCustomerId,
            @Param("destinationCustomerId")
            Long destinationCustomerId
    );

    long countByStatus(
                com.bankease.backend.entity.TransactionStatus status
        );

    @Query("""
            select transaction
            from Transaction transaction
            where transaction.id = :id
              and transaction.sourceAccount.customer.id = :customerId
            """)
    Optional<Transaction>
    findByIdAndSourceAccountCustomerId(
            @Param("id")
            Long id,
            @Param("customerId")
            Long sourceCustomerId
    );

    @Query("""
            select transaction
            from Transaction transaction
            where transaction.id = :id
              and transaction.destinationAccount.customer.id = :customerId
            """)
    Optional<Transaction>
    findByIdAndDestinationAccountCustomerId(
            @Param("id")
            Long id,
            @Param("customerId")
            Long destinationCustomerId
    );
}
