package com.bankease.backend.service;

import com.bankease.backend.entity.ServiceRequest;
import com.bankease.backend.entity.ServiceRequestPriority;
import com.bankease.backend.entity.ServiceRequestStatus;
import com.bankease.backend.entity.AuditAction;
import com.bankease.backend.entity.AuditLog;
import com.bankease.backend.entity.AuditResult;
import com.bankease.backend.entity.AutomationRuleType;
import com.bankease.backend.repository.AuditLogRepository;
import com.bankease.backend.repository.ServiceRequestRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ServiceRequestAutomationService {

    private final ServiceRequestRepository serviceRequestRepository;
    private final AuditLogRepository auditLogRepository;

    public ServiceRequestAutomationService(
            ServiceRequestRepository serviceRequestRepository,
            AuditLogRepository auditLogRepository
    ) {
        this.serviceRequestRepository =
                serviceRequestRepository;
        this.auditLogRepository = auditLogRepository;
    }

    @Transactional
    public int escalateOverdueRequests() {

        LocalDateTime overdueTime =
                LocalDateTime.now().minusHours(48);

        List<ServiceRequest> overdueRequests =
                serviceRequestRepository
                        .findByStatusAndCreatedAtBefore(
                                ServiceRequestStatus.PENDING,
                                overdueTime
                        );

        int updatedCount = 0;

        for (ServiceRequest request : overdueRequests) {

            if (request.getPriority()
                    != ServiceRequestPriority.HIGH) {

                LocalDateTime escalatedAt =
                        LocalDateTime.now();

                request.setPriority(
                        ServiceRequestPriority.HIGH
                );

                request.setUpdatedAt(
                        escalatedAt
                );

                AuditLog auditLog = new AuditLog();
                auditLog.setAction(
                        AuditAction.SERVICE_REQUEST_ESCALATED
                );
                auditLog.setRuleType(
                        AutomationRuleType.OVERDUE_SERVICE_REQUEST
                );
                auditLog.setResult(AuditResult.SUCCESS);
                auditLog.setDescription(
                        "Service request " + request.getId()
                                + " was automatically escalated to HIGH "
                                + "after exceeding 48 hours in PENDING status."
                );
                auditLog.setCreatedAt(escalatedAt);
                auditLogRepository.save(auditLog);

                updatedCount++;
            }
        }

        serviceRequestRepository.saveAll(
                overdueRequests
        );

        return updatedCount;
    }
}
