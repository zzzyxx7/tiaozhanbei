package com.shangfaduxing.rulebackend;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.shangfaduxing.rulebackend.model.JudgeRequest;
import com.shangfaduxing.rulebackend.model.Step2PlanRequest;
import com.shangfaduxing.rulebackend.testsupport.TestDataBootstrap;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.util.HashMap;
import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@ActiveProfiles("test")
@AutoConfigureMockMvc
@Import(TestDataBootstrap.class)
public class RuleApiIntegrationTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;

    @Test
    void questionnaire_judge_step2_should_work_for_all_causes() throws Exception {
        mockMvc.perform(get("/api/rule/causes"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(org.hamcrest.Matchers.greaterThan(0)))
                .andExpect(jsonPath("$[0].causeCode").exists())
                .andExpect(jsonPath("$[0].causeName").exists())
                .andExpect(jsonPath("$[0].questionnaireId").exists());

        for (String cause : TestDataBootstrap.CAUSES) {
            // A) questionnaire
            mockMvc.perform(get("/api/rule/questionnaire").param("causeCode", cause))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$").isArray())
                    .andExpect(jsonPath("$.length()").value(org.hamcrest.Matchers.greaterThan(0)))
                    .andExpect(jsonPath("$[0].questions").isArray());

            // B) judge (Step1)
            JudgeRequest judgeReq = new JudgeRequest();
            judgeReq.setCauseCode(cause);
            Map<String, Object> answers = new HashMap<>();
            answers.put("A1", true);
            judgeReq.setAnswers(answers);

            mockMvc.perform(post("/api/rule/judge")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(judgeReq)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.conclusions").isArray())
                    .andExpect(jsonPath("$.conclusions.length()").value(org.hamcrest.Matchers.greaterThan(0)))
                    .andExpect(jsonPath("$.step2.targets").isArray())
                    .andExpect(jsonPath("$.step2.targets.length()").value(org.hamcrest.Matchers.greaterThan(0)));

            // C) step2
            Step2PlanRequest step2Req = new Step2PlanRequest();
            step2Req.setCauseCode(cause);
            step2Req.setAnswers(answers);
            step2Req.setTargetId(null); // 服务端会自动取第一个 target

            mockMvc.perform(post("/api/rule/step2")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(step2Req)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true))
                    .andExpect(jsonPath("$.factChecklist").isArray())
                    .andExpect(jsonPath("$.factChecklist.length()").value(org.hamcrest.Matchers.greaterThan(0)))
                    .andExpect(jsonPath("$.evidenceChecklist").isArray())
                    .andExpect(jsonPath("$.evidenceChecklist.length()").value(org.hamcrest.Matchers.greaterThan(0)));
        }
    }
}

