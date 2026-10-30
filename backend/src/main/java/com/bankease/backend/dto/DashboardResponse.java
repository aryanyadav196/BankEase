package com.bankease.backend.dto;

public class DashboardResponse {

    private long totalCustomers;
    private long totalAccounts;
    private long activeAccounts;
    private long blockedAccounts;
    private long closedAccounts;

    private long totalTransactions;
    private long completedTransactions;
    private long rejectedTransactions;

    private long pendingServiceRequests;
    private long highPriorityRequests;
    private long overdueServiceRequests;

    public DashboardResponse() {
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

    public long getActiveAccounts() {
        return activeAccounts;
    }

    public void setActiveAccounts(long activeAccounts) {
        this.activeAccounts = activeAccounts;
    }

    public long getBlockedAccounts() {
        return blockedAccounts;
    }

    public void setBlockedAccounts(long blockedAccounts) {
        this.blockedAccounts = blockedAccounts;
    }

    public long getClosedAccounts() {
        return closedAccounts;
    }

    public void setClosedAccounts(long closedAccounts) {
        this.closedAccounts = closedAccounts;
    }

    public long getTotalTransactions() {
        return totalTransactions;
    }

    public void setTotalTransactions(long totalTransactions) {
        this.totalTransactions = totalTransactions;
    }

    public long getCompletedTransactions() {
        return completedTransactions;
    }

    public void setCompletedTransactions(long completedTransactions) {
        this.completedTransactions = completedTransactions;
    }

    public long getRejectedTransactions() {
        return rejectedTransactions;
    }

    public void setRejectedTransactions(long rejectedTransactions) {
        this.rejectedTransactions = rejectedTransactions;
    }

    public long getPendingServiceRequests() {
        return pendingServiceRequests;
    }

    public void setPendingServiceRequests(long pendingServiceRequests) {
        this.pendingServiceRequests = pendingServiceRequests;
    }

    public long getHighPriorityRequests() {
        return highPriorityRequests;
    }

    public void setHighPriorityRequests(long highPriorityRequests) {
        this.highPriorityRequests = highPriorityRequests;
    }

    public long getOverdueServiceRequests() {
        return overdueServiceRequests;
    }

    public void setOverdueServiceRequests(long overdueServiceRequests) {
        this.overdueServiceRequests = overdueServiceRequests;
    }
}