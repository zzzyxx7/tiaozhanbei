package com.shangfaduxing.rulebackend.controller;

import com.shangfaduxing.rulebackend.model.*;
import com.shangfaduxing.rulebackend.service.UserDataService;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rule/user")
public class UserDataController {
    private final UserDataService userDataService;

    public UserDataController(UserDataService userDataService) {
        this.userDataService = userDataService;
    }

    @PostMapping(value = "/session", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public UserSessionCreateResponse createSession(@RequestBody UserSessionCreateRequest request) {
        return userDataService.createSession(request.getUserId(), request.getCauseCode());
    }

    @PostMapping(value = "/judge-save", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public UserJudgeSaveResponse judgeSave(@RequestBody UserJudgeSaveRequest request) {
        return userDataService.judgeAndSave(request);
    }

    @GetMapping("/history")
    public List<UserSubmissionSummary> history(
            @RequestParam("userId") String userId,
            @RequestParam(name = "limit", required = false) Integer limit
    ) {
        return userDataService.history(userId, limit);
    }
}
