package com.shangfaduxing.rulebackend.controller;

import com.shangfaduxing.rulebackend.model.*;
import com.shangfaduxing.rulebackend.service.PrefillWizardService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/rule")
public class ExampleController {
    private final PrefillWizardService prefillWizardService;

    public ExampleController(PrefillWizardService prefillWizardService) {
        this.prefillWizardService = prefillWizardService;
    }

    /**
     * 前端“开始”：输入小类案由 + 示例文案，返回分两步的预填问卷（先 stage1Size，再 stage2Size）。
     */
    @PostMapping(value = "/prefill-wizard", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public PrefillWizardResponse wizard(@RequestBody PrefillWizardRequest request) {
        return prefillWizardService.run(request);
    }
}

