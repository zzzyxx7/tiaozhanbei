package com.shangfaduxing.rulebackend.controller;

import com.shangfaduxing.rulebackend.model.AiPrefillRequest;
import com.shangfaduxing.rulebackend.model.AiPrefillResponse;
import com.shangfaduxing.rulebackend.service.AiPrefillService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/rule")
public class AiController {
    private final AiPrefillService aiPrefillService;

    public AiController(AiPrefillService aiPrefillService) {
        this.aiPrefillService = aiPrefillService;
    }

    @PostMapping(value = "/ai-prefill", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public AiPrefillResponse prefill(@RequestBody AiPrefillRequest request) {
        return aiPrefillService.prefill(request);
    }
}
