package com.bankease.backend.dto;

import com.bankease.backend.entity.AutomationRule;
import com.bankease.backend.entity.AutomationRuleType;

public class AutomationRuleResponse {

    private Long id;
    private String name;
    private AutomationRuleType type;
    private String description;
    private boolean active;

    public AutomationRuleResponse() {
    }

    public static AutomationRuleResponse fromEntity(
            AutomationRule rule
    ) {

        AutomationRuleResponse response =
                new AutomationRuleResponse();

        response.id = rule.getId();
        response.name = rule.getName();
        response.type = rule.getType();
        response.description = rule.getDescription();
        response.active = rule.isActive();

        return response;
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public AutomationRuleType getType() {
        return type;
    }

    public String getDescription() {
        return description;
    }

    public boolean isActive() {
        return active;
    }
}
