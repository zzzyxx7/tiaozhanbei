package com.shangfaduxing.rulebackend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.shangfaduxing.rulebackend.config.MqConfig;
import com.shangfaduxing.rulebackend.model.AiPrefillRequest;
import com.shangfaduxing.rulebackend.model.AiPrefillResponse;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.text.Normalizer;
import java.time.Duration;
import java.util.UUID;

@Service
public class AiPrefillAsyncService {
    private final RabbitTemplate rabbitTemplate;
    private final StringRedisTemplate redisTemplate;
    private final ObjectMapper objectMapper;
    private final AiPrefillService aiPrefillService;

    @Value("${ai.prefill.async.task-ttl-seconds:3600}")
    private long taskTtlSeconds;

    public AiPrefillAsyncService(
            RabbitTemplate rabbitTemplate,
            StringRedisTemplate redisTemplate,
            ObjectMapper objectMapper,
            AiPrefillService aiPrefillService
    ) {
        this.rabbitTemplate = rabbitTemplate;
        this.redisTemplate = redisTemplate;
        this.objectMapper = objectMapper;
        this.aiPrefillService = aiPrefillService;
    }

    public String submit(AiPrefillRequest request) throws Exception {
        String fp = fingerprint(request);
        String dedupKey = keyDedup(fp);
        String existingTaskId = redisTemplate.opsForValue().get(dedupKey);
        if (existingTaskId != null && !existingTaskId.isBlank()) {
            String status = redisTemplate.opsForValue().get(keyStatus(existingTaskId));
            if (status != null && !status.isBlank() && !"failed".equals(status)) {
                return existingTaskId;
            }
        }

        String taskId = UUID.randomUUID().toString().replace("-", "");
        String keyStatus = keyStatus(taskId);
        String keyReq = keyReq(taskId);
        Duration ttl = Duration.ofSeconds(Math.max(60, taskTtlSeconds));

        redisTemplate.opsForValue().set(keyStatus, "queued", ttl);
        redisTemplate.opsForValue().set(keyReq, objectMapper.writeValueAsString(request), ttl);
        redisTemplate.opsForValue().set(dedupKey, taskId, ttl);

        rabbitTemplate.convertAndSend(MqConfig.EXCHANGE, MqConfig.RK_PREFILL, taskId);
        return taskId;
    }

    public String getStatus(String taskId) {
        return redisTemplate.opsForValue().get(keyStatus(taskId));
    }

    public AiPrefillResponse getResult(String taskId) {
        try {
            String json = redisTemplate.opsForValue().get(keyResult(taskId));
            if (json == null || json.isBlank()) return null;
            return objectMapper.readValue(json, AiPrefillResponse.class);
        } catch (Exception e) {
            return null;
        }
    }

    @RabbitListener(queues = MqConfig.QUEUE_PREFILL)
    public void handlePrefillTask(String taskId) {
        String statusKey = keyStatus(taskId);
        try {
            redisTemplate.opsForValue().set(statusKey, "running", Duration.ofSeconds(Math.max(60, taskTtlSeconds)));

            String reqJson = redisTemplate.opsForValue().get(keyReq(taskId));
            if (reqJson == null || reqJson.isBlank()) {
                redisTemplate.opsForValue().set(statusKey, "failed", Duration.ofSeconds(Math.max(60, taskTtlSeconds)));
                return;
            }
            AiPrefillRequest req = objectMapper.readValue(reqJson, AiPrefillRequest.class);
            AiPrefillResponse resp = aiPrefillService.prefill(req);

            redisTemplate.opsForValue().set(keyResult(taskId), objectMapper.writeValueAsString(resp),
                    Duration.ofSeconds(Math.max(60, taskTtlSeconds)));
            redisTemplate.opsForValue().set(statusKey, "success", Duration.ofSeconds(Math.max(60, taskTtlSeconds)));
        } catch (Exception e) {
            redisTemplate.opsForValue().set(statusKey, "failed", Duration.ofSeconds(Math.max(60, taskTtlSeconds)));
            redisTemplate.opsForValue().set(keyError(taskId), String.valueOf(e.getMessage()),
                    Duration.ofSeconds(Math.max(60, taskTtlSeconds)));
        }
    }

    public String getError(String taskId) {
        return redisTemplate.opsForValue().get(keyError(taskId));
    }

    private static String keyStatus(String taskId) {
        return "ai:prefill:task:" + taskId + ":status";
    }

    private static String keyReq(String taskId) {
        return "ai:prefill:task:" + taskId + ":req";
    }

    private static String keyResult(String taskId) {
        return "ai:prefill:task:" + taskId + ":result";
    }

    private static String keyError(String taskId) {
        return "ai:prefill:task:" + taskId + ":error";
    }

    private static String keyDedup(String fingerprint) {
        return "ai:prefill:dedup:" + fingerprint;
    }

    private static String fingerprint(AiPrefillRequest request) {
        String causeCode = normalize(request == null ? "" : request.getCauseCode());
        String provider = normalize(request == null ? "" : request.getProvider());
        String userText = normalize(request == null ? "" : request.getUserText());
        return sha256(causeCode + "|" + provider + "|" + userText);
    }

    private static String normalize(String s) {
        if (s == null) return "";
        return Normalizer.normalize(s, Normalizer.Form.NFKC).trim().replaceAll("\\s+", " ");
    }

    private static String sha256(String input) {
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

