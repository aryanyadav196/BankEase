package com.bankease.backend.controller;

import com.bankease.backend.dto.DashboardResponse;
import com.bankease.backend.service.DashboardService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    private final DashboardService dashboardService;

    public DashboardController(
            DashboardService dashboardService
    ) {
        this.dashboardService = dashboardService;
    }

    @PreAuthorize("hasAnyRole('EMPLOYEE', 'ADMIN')")
    @GetMapping
    public ResponseEntity<DashboardResponse> getDashboard() {

        DashboardResponse response =
                dashboardService.getDashboard();

        return ResponseEntity.ok(response);
    }
}