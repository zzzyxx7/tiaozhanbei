package com.shangfaduxing.rulebackend.service;

import com.shangfaduxing.rulebackend.model.CaseItem;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CaseLibraryService {
    private final JdbcTemplate jdbcTemplate;

    public CaseLibraryService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<CaseItem> query(String causeCode, String keyword, Integer limit) {
        int safeLimit = (limit == null || limit <= 0 || limit > 50) ? 10 : limit;
        String sql = "SELECT id, cause_code, case_no, title, court, judgment_date, keywords, summary, source_url " +
                "FROM rule_case_library WHERE enabled=1 " +
                "AND (? IS NULL OR ? = '' OR cause_code=?) " +
                "AND (? IS NULL OR ? = '' OR title LIKE CONCAT('%', ?, '%') OR summary LIKE CONCAT('%', ?, '%') OR keywords LIKE CONCAT('%', ?, '%')) " +
                "ORDER BY judgment_date DESC, id DESC LIMIT ?";
        return jdbcTemplate.query(sql, (rs, i) -> {
                    CaseItem c = new CaseItem();
                    c.setId(rs.getLong("id"));
                    c.setCauseCode(rs.getString("cause_code"));
                    c.setCaseNo(rs.getString("case_no"));
                    c.setTitle(rs.getString("title"));
                    c.setCourt(rs.getString("court"));
                    c.setJudgmentDate(rs.getString("judgment_date"));
                    c.setKeywords(rs.getString("keywords"));
                    c.setSummary(rs.getString("summary"));
                    c.setUrl(rs.getString("source_url"));
                    return c;
                },
                causeCode, causeCode, causeCode,
                keyword, keyword, keyword, keyword, keyword,
                safeLimit
        );
    }
}
