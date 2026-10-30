package com.bankease.backend.dto;

public class AdminOverviewResponse {

    private long totalUsers;
    private long totalCustomers;
    private long totalAccounts;
    private long totalTransactions;
    private long pendingServiceRequests;
    private long blockedAccounts;
    private long rejectedTransactions;
    private long totalAuditLogs;
    private long activeAutomationRules;

    public AdminOverviewResponse() {
    }

    public long getTotalUsers() {
        return totalUsers;
    }

    public void setTotalUsers(long totalUsers) {
        this.totalUsers = totalUsers;
    }

    public long getTotalCustomers() {
        return totalCustomers;
    }

    public void setTotalCustomers(long totalCustomers) {
        this.totalCustomers = totalCustomers;
    }

    public long getTotalAccounts() {
        return totalAccounts;
    }

    public void setTotalAccounts(long totalAccounts) {
        this.totalAccounts = totalAccounts;
    }

    public long getTotalTransactions() {
        return totalTransactions;
    }

    public void setTotalTransactions(long totalTransactions) {
        this.totalTransactions = totalTransactions;
    }

    public long getPendingServiceRequests() {
        return pendingServiceRequests;
    }

    public void setPendingServiceRequests(
            long pendingServiceRequests
    ) {
        this.pendingServiceRequests =
                pendingServiceRequests;
    }

    public long getBlockedAccounts() {
        return blockedAccounts;
    }

    public void setBlockedAccounts(long blockedAccounts) {
        this.blockedAccounts = blockedAccounts;
    }

    public long getRejectedTransactions() {
        return rejectedTransactions;
    }

    public void setRejectedTransactions(
            long rejectedTransactions
    ) {
        this.rejectedTransactions =
                rejectedTransactions;
    }

    public long getTotalAuditLogs() {
        return totalAuditLogs;
    }

    public void setTotalAuditLogs(long totalAuditLogs) {
        this.totalAuditLogs = totalAuditLogs;
    }

    public long getActiveAutomationRules() {
        return activeAutomationRules;
    }

    public void setActiveAutomationRules(
            long activeAutomationRules
    ) {
        this.activeAutomationRules =
                activeAutomationRules;
    }
}