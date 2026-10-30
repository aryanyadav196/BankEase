package com.bankease.backend.service;

import com.bankease.backend.entity.AutomationRuleType;

public class RuleEvaluationResult {

    private final boolean allowed;
    private final AutomationRuleType ruleType;
    private final String message;

    public RuleEvaluationResult(
            boolean allowed,
            AutomationRuleType ruleType,
            String message
    ) {
        this.allowed = allowed;
        this.ruleType = ruleType;
        this.message = message;
    }

    public boolean isAllowed() {
        return allowed;
    }

    public AutomationRuleType getRuleType() {
        return ruleType;
    }

    public String getMessage() {
        return message;
    }
}