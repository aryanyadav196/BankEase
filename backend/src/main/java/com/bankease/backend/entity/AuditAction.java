package com.bankease.backend.entity;

public enum AuditAction {
    TRANSACTION_REJECTED,
    TRANSACTION_COMPLETED,
    BALANCE_UPDATED,
    SERVICE_REQUEST_ESCALATED,
    RULE_APPLIED
}