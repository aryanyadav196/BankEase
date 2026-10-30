package com.bankease.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "automation_rules")
public class AutomationRule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, unique = true, length = 40)
    private AutomationRuleType type;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 500)
    private String description;

    @Column(nullable = false)
    private boolean active = true;

    public AutomationRule() {
    }

    public Long getId() {
        return id;
    }

    public AutomationRuleType getType() {
        return type;
    }

    public void setType(AutomationRuleType type) {
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}