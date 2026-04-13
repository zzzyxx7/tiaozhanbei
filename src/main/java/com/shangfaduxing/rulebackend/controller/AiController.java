package com.shangfaduxing.rulebackend.controller;

import com.shangfaduxing.rulebackend.model.AiPrefillRequest;
import com.shangfaduxing.rulebackend.model.AiPrefillResponse;
import com.shangfaduxing.rulebackend.model.AiPrefillSubmitResponse;
import com.shangfaduxing.rulebackend.model.AiPrefillTaskResponse;
import com.shangfaduxing.rulebackend.service.AiPrefillAsyncService;
import com.shangfaduxing.rulebackend.service.AiPrefillService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.text.Normalizer;
import java.time.Duration;
import java.util.LinkedHashMap;
import java.util.List;

@RestController
@RequestMapping("/api/rule")
public class AiController {
    private final AiPrefillService aiPrefillService;
    private final AiPrefillAsyncService aiPrefillAsyncService;
    private final StringRedisTemplate redisTemplate;

    @Value("${ai.prefill.debounce-ms:8000}")
    private long debounceMs;

    public AiController(AiPrefillService aiPrefillService, AiPrefillAsyncService aiPrefillAsyncService, StringRedisTemplate redisTemplate) {
        this.aiPrefillService = aiPrefillService;
        this.aiPrefillAsyncService = aiPrefillAsyncService;
        this.redisTemplate = redisTemplate;
    }

    @PostMapping(value = "/ai-prefill", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public AiPrefillResponse prefill(@RequestBody AiPrefillRequest request, HttpServletRequest httpServletRequest) {
        if (isDuplicate(request, httpServletRequest)) {
            AiPrefillResponse resp = new AiPrefillResponse();
            resp.setSuccess(false);
            resp.setMessage("请求过于频繁，请稍后再试");
            resp.setProvider(request == null ? null : request.getProvider());
            resp.setFallback(false);
            resp.setSuggestions(List.of());
            resp.setMergedAnswers(request == null || request.getExistingAnswers() == null
                    ? new LinkedHashMap<>()
                    : new LinkedHashMap<>(request.getExistingAnswers()));
            return resp;
        }
        return aiPrefillService.prefill(request);
    }

    /**
     * 异步提交 AI 预填任务：立即返回 taskId，前端轮询 /ai-prefill/task/{taskId} 获取结果。
     */
    @PostMapping(value = "/ai-prefill/submit", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public AiPrefillSubmitResponse submit(@RequestBody AiPrefillRequest request, HttpServletRequest httpServletRequest) {
        AiPrefillSubmitResponse resp = new AiPrefillSubmitResponse();
        try {
            if (isDuplicate(request, httpServletRequest)) {
                resp.setSuccess(false);
                resp.setMessage("请求过于频繁，请稍后再试");
                return resp;
            }
            if (request == null) {
                resp.setSuccess(false);
                resp.setMessage("请求不能为空");
                return resp;
            }
            String taskId = aiPrefillAsyncService.submit(request);
            resp.setSuccess(true);
            resp.setTaskId(taskId);
            resp.setMessage("任务已提交");
            return resp;
        } catch (Exception e) {
            resp.setSuccess(false);
            resp.setMessage("提交失败: " + e.getMessage());
            return resp;
        }
    }

    @GetMapping(value = "/ai-prefill/task/{taskId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public AiPrefillTaskResponse task(@PathVariable("taskId") String taskId) {
        AiPrefillTaskResponse resp = new AiPrefillTaskResponse();
        resp.setTaskId(taskId);
        String status = aiPrefillAsyncService.getStatus(taskId);
        if (status == null || status.isBlank()) {
            resp.setSuccess(false);
            resp.setStatus("not_found");
            resp.setMessage("任务不存在或已过期");
            return resp;
        }
        resp.setSuccess(true);
        resp.setStatus(status);
        if ("success".equals(status)) {
            resp.setResult(aiPrefillAsyncService.getResult(taskId));
            resp.setMessage("任务完成");
        } else if ("failed".equals(status)) {
            resp.setMessage("任务失败: " + safe(aiPrefillAsyncService.getError(taskId)));
        } else {
            resp.setMessage("任务处理中");
        }
        return resp;
    }

    private boolean isDuplicate(AiPrefillRequest request, HttpServletRequest servletRequest) {
        if (debounceMs <= 0) return false;
        if (request == null) return false;
        String causeCode = safe(request.getCauseCode());
        String userText = normalizeUserText(request.getUserText());
        if (causeCode.isBlank() || userText.isBlank()) return false;

        String ip = resolveClientIp(servletRequest);
        String raw = ip + "|" + causeCode + "|" + userText;
        String key = "ai:prefill:debounce:" + sha256Hex(raw);

        Boolean ok = redisTemplate.opsForValue().setIfAbsent(key, "1", Duration.ofMillis(debounceMs));
        return ok == null || !ok;
    }

    private static String resolveClientIp(HttpServletRequest request) {
        if (request == null) return "unknown";
        String xff = request.getHeader("X-Forwarded-For");
        if (xff != null && !xff.isBlank()) {
            // 取第一个，避免拼接多级代理导致 key 超长
            int idx = xff.indexOf(',');
            return (idx >= 0 ? xff.substring(0, idx) : xff).trim();
        }
        String xri = request.getHeader("X-Real-IP");
        if (xri != null && !xri.isBlank()) return xri.trim();
        return request.getRemoteAddr() == null ? "unknown" : request.getRemoteAddr();
    }

    private static String normalizeUserText(String text) {
        if (text == null) return "";
        String t = Normalizer.normalize(text, Normalizer.Form.NFKC).trim();
        // 合并连续空白，避免同一句话不同空格导致绕过防抖
        return t.replaceAll("\\s+", " ");
    }

    private static String safe(String s) {
        return s == null ? "" : s.trim();
    }

    private static String sha256Hex(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] out = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(out.length * 2);
            for (byte b : out) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            return Integer.toHexString(input.hashCode());
        }
    }
}
