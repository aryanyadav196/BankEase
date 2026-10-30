package com.bankease.backend.repository;

import com.bankease.backend.entity.AutomationRule;
import com.bankease.backend.entity.AutomationRuleType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AutomationRuleRepository
        extends JpaRepository<AutomationRule, Long> {

    Optional<AutomationRule> findByType(
            AutomationRuleType type
    );

    long countByActiveTrue();
}