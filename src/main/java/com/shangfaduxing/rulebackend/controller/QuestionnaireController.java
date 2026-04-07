package com.shangfaduxing.rulebackend.controller;

import com.shangfaduxing.rulebackend.service.RuleCenterService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/rule")
public class QuestionnaireController {

    private final RuleCenterService ruleCenterService;

    public QuestionnaireController(RuleCenterService ruleCenterService) {
        this.ruleCenterService = ruleCenterService;
    }

    @GetMapping("/questionnaire")
    public List<Map<String, Object>> questionnaire(
            @RequestParam(name = "questionnaireId", defaultValue = "questionnaire_divorce_property_split") String questionnaireId,
            @RequestParam(name = "causeCode", required = false) String causeCode
    ) {
        return ruleCenterService.questionnaire(causeCode, questionnaireId);
    }
}

