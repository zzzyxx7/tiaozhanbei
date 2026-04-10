package com.shangfaduxing.rulebackend.controller;

import com.shangfaduxing.rulebackend.model.ReportRequest;
import com.shangfaduxing.rulebackend.model.ReportResponse;
import com.shangfaduxing.rulebackend.service.ReportService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/rule")
public class ReportController {
    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @PostMapping(value = "/report", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public ReportResponse report(@RequestBody ReportRequest request) {
        return reportService.generate(request.getCauseCode(), request.getAnswers(), request.getTitle());
    }
}
