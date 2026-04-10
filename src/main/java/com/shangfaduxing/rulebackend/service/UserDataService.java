package com.shangfaduxing.rulebackend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;
import com.shangfaduxing.rulebackend.model.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.sql.PreparedStatement;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class UserDataService {
    private final JdbcTemplate jdbcTemplate;
    private final RuleCenterService ruleCenterService;
    private final ReportService reportService;
    private final ObjectMapper objectMapper;
    private final StringRedisTemplate redisTemplate;

    private static final Duration SESSION_TTL = Duration.ofHours(24);
    private static final Duration HISTORY_TTL = Duration.ofHours(6);
    private static final int HISTORY_CACHE_LIMIT = 50;

    public UserDataService(JdbcTemplate jdbcTemplate, RuleCenterService ruleCenterService, ReportService reportService, ObjectMapper objectMapper, StringRedisTemplate redisTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        this.ruleCenterService = ruleCenterService;
        this.reportService = reportService;
        this.objectMapper = objectMapper;
        this.redisTemplate = redisTemplate;
    }

    public UserSessionCreateResponse createSession(String userId, String causeCode) {
        UserSessionCreateResponse resp = new UserSessionCreateResponse();
        if (isBlank(userId) || isBlank(causeCode)) {
            resp.setSuccess(false);
            resp.setMessage("userId 和 causeCode 不能为空");
            return resp;
        }
        if (!causeExists(causeCode)) {
            resp.setSuccess(false);
            resp.setMessage("causeCode 不存在或未启用");
            return resp;
        }
        String sessionId = UUID.randomUUID().toString().replace("-", "");
        jdbcTemplate.update(
                "INSERT INTO rule_user_session(session_id, user_id, cause_code, status) VALUES(?,?,?,?)",
                sessionId, userId, causeCode, "active"
        );
        resp.setSuccess(true);
        resp.setSessionId(sessionId);
        resp.setUserId(userId);
        resp.setCauseCode(causeCode);
        resp.setStatus("active");
        resp.setMessage("会话创建成功");
        cacheSession(sessionId, userId, causeCode);
        return resp;
    }

    public UserJudgeSaveResponse judgeAndSave(UserJudgeSaveRequest request) {
        UserJudgeSaveResponse resp = new UserJudgeSaveResponse();
        try {
            if (request == null || isBlank(request.getUserId()) || isBlank(request.getCauseCode()) || request.getAnswers() == null) {
                resp.setSuccess(false);
                resp.setMessage("userId、causeCode、answers 不能为空");
                return resp;
            }
            if (!causeExists(request.getCauseCode())) {
                resp.setSuccess(false);
                resp.setMessage("causeCode 不存在或未启用");
                return resp;
            }

            String sessionId = normalizeSession(request.getSessionId(), request.getUserId(), request.getCauseCode(), resp);
            if (!resp.isSuccess() && resp.getMessage() != null) {
                return resp;
            }

            JudgeResponse judge = ruleCenterService.judge(request.getCauseCode(), request.getAnswers());
            ReportResponse report = reportService.generate(request.getCauseCode(), request.getAnswers(), request.getReportTitle());
            String answersJson = objectMapper.writeValueAsString(request.getAnswers());
            String judgeJson = objectMapper.writeValueAsString(judge);

            KeyHolder keyHolder = new GeneratedKeyHolder();
            String finalSessionId = sessionId;
            jdbcTemplate.update(connection -> {
                PreparedStatement ps = connection.prepareStatement(
                        "INSERT INTO rule_user_submission(session_id, user_id, cause_code, answers_json, judge_json, report_markdown) VALUES(?,?,?,?,?,?)",
                        new String[]{"id"}
                );
                ps.setString(1, finalSessionId);
                ps.setString(2, request.getUserId());
                ps.setString(3, request.getCauseCode());
                ps.setString(4, answersJson);
                ps.setString(5, judgeJson);
                ps.setString(6, report.getMarkdown());
                return ps;
            }, keyHolder);

            Long id = keyHolder.getKey() == null ? null : keyHolder.getKey().longValue();
            jdbcTemplate.update("UPDATE rule_user_session SET last_active_at=NOW(), status=? WHERE session_id=?", "active", sessionId);
            resp.setSuccess(true);
            resp.setSessionId(sessionId);
            resp.setSubmissionId(id);
            resp.setJudge(judge);
            resp.setReportMarkdown(report.getMarkdown());
            resp.setMessage("判定并保存成功");
            cacheSession(sessionId, request.getUserId(), request.getCauseCode());
            cacheHistoryItem(id, sessionId, request.getUserId(), request.getCauseCode());
            return resp;
        } catch (Exception e) {
            resp.setSuccess(false);
            resp.setMessage("保存失败: " + e.getMessage());
            return resp;
        }
    }

    public List<UserSubmissionSummary> history(String userId, Integer limit) {
        if (isBlank(userId)) return List.of();
        int safeLimit = (limit == null || limit <= 0 || limit > 100) ? 20 : limit;
        List<UserSubmissionSummary> cached = readHistoryFromCache(userId, safeLimit);
        if (!cached.isEmpty()) return cached;
        return jdbcTemplate.query(
                "SELECT id, session_id, user_id, cause_code, created_at FROM rule_user_submission WHERE user_id=? ORDER BY created_at DESC LIMIT ?",
                (rs, i) -> {
                    UserSubmissionSummary s = new UserSubmissionSummary();
                    s.setId(rs.getLong("id"));
                    s.setSessionId(rs.getString("session_id"));
                    s.setUserId(rs.getString("user_id"));
                    s.setCauseCode(rs.getString("cause_code"));
                    s.setCreatedAt(rs.getString("created_at"));
                    return s;
                },
                userId, safeLimit
        ).stream().peek(s -> cacheHistoryItem(s.getId(), s.getSessionId(), s.getUserId(), s.getCauseCode())).toList();
    }

    private boolean causeExists(String causeCode) {
        Integer cnt = jdbcTemplate.queryForObject(
                "SELECT COUNT(1) FROM rule_cause WHERE cause_code=? AND enabled=1",
                Integer.class,
                causeCode
        );
        return cnt != null && cnt > 0;
    }

    private String normalizeSession(String sessionId, String userId, String causeCode, UserJudgeSaveResponse resp) {
        if (isBlank(sessionId)) {
            String newSessionId = UUID.randomUUID().toString().replace("-", "");
            jdbcTemplate.update(
                    "INSERT INTO rule_user_session(session_id, user_id, cause_code, status) VALUES(?,?,?,?)",
                    newSessionId, userId, causeCode, "active"
            );
            cacheSession(newSessionId, userId, causeCode);
            return newSessionId;
        }
        Map<String, String> sessionCache = readSessionFromCache(sessionId);
        if (!sessionCache.isEmpty()) {
            String cachedUserId = sessionCache.get("userId");
            String cachedCauseCode = sessionCache.get("causeCode");
            if (!userId.equals(cachedUserId)) {
                resp.setSuccess(false);
                resp.setMessage("sessionId 与 userId 不匹配");
                return sessionId;
            }
            if (!causeCode.equals(cachedCauseCode)) {
                resp.setSuccess(false);
                resp.setMessage("sessionId 与 causeCode 不匹配");
                return sessionId;
            }
            return sessionId;
        }
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
                "SELECT user_id, cause_code FROM rule_user_session WHERE session_id=?",
                sessionId
        );
        if (rows.isEmpty()) {
            resp.setSuccess(false);
            resp.setMessage("sessionId 不存在，请先创建会话");
            return sessionId;
        }
        String sessionUserId = String.valueOf(rows.get(0).get("user_id"));
        String sessionCauseCode = String.valueOf(rows.get(0).get("cause_code"));
        if (!userId.equals(sessionUserId)) {
            resp.setSuccess(false);
            resp.setMessage("sessionId 与 userId 不匹配");
            return sessionId;
        }
        if (!causeCode.equals(sessionCauseCode)) {
            resp.setSuccess(false);
            resp.setMessage("sessionId 与 causeCode 不匹配");
            return sessionId;
        }
        cacheSession(sessionId, sessionUserId, sessionCauseCode);
        return sessionId;
    }

    private boolean isBlank(String s) {
        return s == null || s.isBlank();
    }

    private String keySession(String sessionId) {
        return "rule:user:session:" + sessionId;
    }

    private String keyHistory(String userId) {
        return "rule:user:history:" + userId;
    }

    private void cacheSession(String sessionId, String userId, String causeCode) {
        try {
            String key = keySession(sessionId);
            redisTemplate.opsForHash().put(key, "userId", userId);
            redisTemplate.opsForHash().put(key, "causeCode", causeCode);
            redisTemplate.expire(key, SESSION_TTL);
        } catch (Exception ignored) {
        }
    }

    private Map<String, String> readSessionFromCache(String sessionId) {
        try {
            Map<Object, Object> raw = redisTemplate.opsForHash().entries(keySession(sessionId));
            if (raw == null || raw.isEmpty()) return Map.of();
            String userId = String.valueOf(raw.getOrDefault("userId", ""));
            String causeCode = String.valueOf(raw.getOrDefault("causeCode", ""));
            if (isBlank(userId) || isBlank(causeCode)) return Map.of();
            return Map.of("userId", userId, "causeCode", causeCode);
        } catch (Exception ignored) {
            return Map.of();
        }
    }

    private void cacheHistoryItem(Long id, String sessionId, String userId, String causeCode) {
        if (id == null || isBlank(userId)) return;
        try {
            UserSubmissionSummary s = new UserSubmissionSummary();
            s.setId(id);
            s.setSessionId(sessionId);
            s.setUserId(userId);
            s.setCauseCode(causeCode);
            s.setCreatedAt(String.valueOf(System.currentTimeMillis()));
            String json = objectMapper.writeValueAsString(s);
            String key = keyHistory(userId);
            redisTemplate.opsForList().leftPush(key, json);
            redisTemplate.opsForList().trim(key, 0, HISTORY_CACHE_LIMIT - 1);
            redisTemplate.expire(key, HISTORY_TTL);
        } catch (Exception ignored) {
        }
    }

    private List<UserSubmissionSummary> readHistoryFromCache(String userId, int limit) {
        try {
            List<String> rows = redisTemplate.opsForList().range(keyHistory(userId), 0, limit - 1);
            if (rows == null || rows.isEmpty()) return List.of();
            List<UserSubmissionSummary> out = new ArrayList<>();
            for (String json : rows) {
                out.add(objectMapper.readValue(json, new TypeReference<UserSubmissionSummary>() {
                }));
            }
            return out;
        } catch (Exception ignored) {
            return List.of();
        }
    }
}
