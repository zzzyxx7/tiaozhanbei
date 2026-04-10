package com.shangfaduxing.rulebackend.controller;

import com.shangfaduxing.rulebackend.model.CaseItem;
import com.shangfaduxing.rulebackend.service.CaseLibraryService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/rule")
public class CaseLibraryController {
    private final CaseLibraryService caseLibraryService;

    public CaseLibraryController(CaseLibraryService caseLibraryService) {
        this.caseLibraryService = caseLibraryService;
    }

    @GetMapping("/cases")
    public List<CaseItem> cases(
            @RequestParam(name = "causeCode", required = false) String causeCode,
            @RequestParam(name = "keyword", required = false) String keyword,
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        return caseLibraryService.query(causeCode, keyword, limit);
    }
}
