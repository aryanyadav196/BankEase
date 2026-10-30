package com.bankease.backend.service;

import com.bankease.backend.entity.AuditAction;
import com.bankease.backend.entity.AuditLog;
import com.bankease.backend.entity.AuditResult;
import com.bankease.backend.entity.AutomationRuleType;
import com.bankease.backend.entity.User;
import com.bankease.backend.repository.AuditLogRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class RuleAutomationService {

    private final AuditLogRepository auditLogRepository;

    public RuleAutomationService(AuditLogRepository auditLogRepository) {
        this.auditLogRepository = auditLogRepository;
    }

    public AuditLog recordRuleResult(
            RuleEvaluationResult evaluationResult,
            User user
    ) {

        AuditLog auditLog = new AuditLog();

        auditLog.setRuleType(evaluationResult.getRuleType());
        auditLog.setDescription(evaluationResult.getMessage());
        auditLog.setCreatedAt(LocalDateTime.now());
        auditLog.setUser(user);

        if (evaluationResult.isAllowed()) {
            auditLog.setAction(AuditAction.RULE_APPLIED);
            auditLog.setResult(AuditResult.SUCCESS);
        } else {
            auditLog.setAction(AuditAction.TRANSACTION_REJECTED);
            auditLog.setResult(AuditResult.REJECTED);
        }

        return auditLogRepository.save(auditLog);
    }
}