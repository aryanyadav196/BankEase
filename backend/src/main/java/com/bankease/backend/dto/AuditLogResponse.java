package com.bankease.backend.dto;

import com.bankease.backend.entity.AuditAction;
import com.bankease.backend.entity.AuditLog;
import com.bankease.backend.entity.AuditResult;
import com.bankease.backend.entity.AutomationRuleType;

import java.time.LocalDateTime;

public class AuditLogResponse {

    private Long id;
    private AuditAction action;
    private AutomationRuleType ruleType;
    private String description;
    private AuditResult result;
    private LocalDateTime createdAt;
    private String user;

    public AuditLogResponse() {
    }

    public static AuditLogResponse fromEntity(AuditLog auditLog) {

        AuditLogResponse response = new AuditLogResponse();

        response.id = auditLog.getId();
        response.action = auditLog.getAction();
        response.ruleType = auditLog.getRuleType();
        response.description = auditLog.getDescription();
        response.result = auditLog.getResult();
        response.createdAt = auditLog.getCreatedAt();
        response.user = auditLog.getUser() == null
                ? null
                : auditLog.getUser().getEmail();

        return response;
    }

    public Long getId() {
        return id;
    }

    public AuditAction getAction() {
        return action;
    }

    public AutomationRuleType getRuleType() {
        return ruleType;
    }

    public String getDescription() {
        return description;
    }

    public AuditResult getResult() {
        return result;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public String getUser() {
        return user;
    }
}
