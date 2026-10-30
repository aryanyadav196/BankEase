package com.bankease.backend.service;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class ServiceRequestScheduler {

    private final ServiceRequestAutomationService
            serviceRequestAutomationService;

    public ServiceRequestScheduler(
            ServiceRequestAutomationService
                    serviceRequestAutomationService
    ) {
        this.serviceRequestAutomationService =
                serviceRequestAutomationService;
    }

    @Scheduled(fixedRate = 3600000)
    public void checkOverdueRequests() {

        int updatedCount =
                serviceRequestAutomationService
                        .escalateOverdueRequests();

        if (updatedCount > 0) {

            System.out.println(
                    "BankEase automation: " +
                    updatedCount +
                    " overdue service request(s) escalated."
            );
        }
    }
}