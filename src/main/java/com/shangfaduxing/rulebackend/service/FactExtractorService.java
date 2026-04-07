package com.shangfaduxing.rulebackend.service;

import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class FactExtractorService {
    private static final String CAUSE_DIVORCE = "divorce_property";
    private static final String CAUSE_UNPAID = "labor_unpaid_wages";
    private static final String CAUSE_NO_CONTRACT = "labor_no_contract";

    private final RuleEngineService ruleEngineService;

    public FactExtractorService(RuleEngineService ruleEngineService) {
        this.ruleEngineService = ruleEngineService;
    }

    public Map<String, Object> extractByCause(String causeCode, Map<String, Object> answers) {
        if (CAUSE_DIVORCE.equals(causeCode)) {
            return ruleEngineService.extractFacts(answers);
        }
        if (CAUSE_UNPAID.equals(causeCode)) {
            return extractLaborUnpaid(answers);
        }
        if (CAUSE_NO_CONTRACT.equals(causeCode)) {
            return extractLaborNoContract(answers);
        }
        return extractLaborTermination(answers);
    }

    private Map<String, Object> extractLaborUnpaid(Map<String, Object> answers) {
        Map<String, Object> facts = new LinkedHashMap<>();
        Map<String, Object> safeAnswers = answers == null ? Map.of() : answers;
        putB(facts, safeAnswers, "存在劳动关系");
        putB(facts, safeAnswers, "已提供劳动");
        putB(facts, safeAnswers, "存在欠薪");
        putB(facts, safeAnswers, "入职时间已明确");
        putB(facts, safeAnswers, "离职时间已明确");
        putB(facts, safeAnswers, "有工资约定依据");
        putB(facts, safeAnswers, "有考勤或工作记录");
        putB(facts, safeAnswers, "有工资支付记录");
        putB(facts, safeAnswers, "有催要工资记录");
        putB(facts, safeAnswers, "单位书面承认欠薪");
        putB(facts, safeAnswers, "有明确工资周期约定");
        putB(facts, safeAnswers, "主张加班费");
        putB(facts, safeAnswers, "有加班事实证据");
        putB(facts, safeAnswers, "有加班工资约定依据");
        putB(facts, safeAnswers, "主张解除补偿");
        putB(facts, safeAnswers, "解除原因偏向单位责任");
        putB(facts, safeAnswers, "已向劳动监察投诉");
        putB(facts, safeAnswers, "单位逾期仍未支付");
        facts.put("欠薪金额", numberOr0(safeAnswers.get("欠薪金额")));
        facts.put("欠薪时长", intOr0(safeAnswers.get("欠薪时长")));
        return facts;
    }

    private Map<String, Object> extractLaborNoContract(Map<String, Object> answers) {
        Map<String, Object> facts = new LinkedHashMap<>();
        Map<String, Object> safeAnswers = answers == null ? Map.of() : answers;
        putB(facts, safeAnswers, "存在劳动关系");
        putB(facts, safeAnswers, "未签书面劳动合同");
        putB(facts, safeAnswers, "已补签劳动合同");
        putB(facts, safeAnswers, "有工资支付记录");
        putB(facts, safeAnswers, "有工作管理证据");
        putB(facts, safeAnswers, "单位拒绝签合同");
        putB(facts, safeAnswers, "主张补签书面合同");
        putB(facts, safeAnswers, "主张无固定期限合同");
        putB(facts, safeAnswers, "满足无固定期限条件");
        facts.put("入职月数", intOr0(safeAnswers.get("入职月数")));
        return facts;
    }

    private Map<String, Object> extractLaborTermination(Map<String, Object> answers) {
        Map<String, Object> facts = new LinkedHashMap<>();
        Map<String, Object> safeAnswers = answers == null ? Map.of() : answers;
        putB(facts, safeAnswers, "存在劳动关系");
        putB(facts, safeAnswers, "已被解除或辞退");
        putB(facts, safeAnswers, "有解除通知");
        putB(facts, safeAnswers, "解除通知为书面");
        putB(facts, safeAnswers, "提前30日通知或支付代通知金");
        putB(facts, safeAnswers, "单位是否履行工会程序");
        putB(facts, safeAnswers, "规章制度已公示且合法");
        putB(facts, safeAnswers, "处于特殊保护期");
        putB(facts, safeAnswers, "单位有严重违纪证据");
        putB(facts, safeAnswers, "经济性裁员符合法定人数与报告程序");
        putB(facts, safeAnswers, "主张继续履行劳动合同");
        putB(facts, safeAnswers, "主张停工期间工资损失");
        String reason = str(safeAnswers.get("解除理由类型"));
        facts.put("解除理由_39", "article_39".equals(reason));
        facts.put("解除理由_40", "article_40".equals(reason));
        facts.put("解除理由_41", "article_41".equals(reason));
        facts.put("解除理由不明确", reason == null || reason.isBlank() || "unknown".equals(reason));
        return facts;
    }

    private static void putB(Map<String, Object> facts, Map<String, Object> answers, String key) {
        facts.put(key, isTrue(answers.get(key)));
    }

    private static boolean isTrue(Object v) {
        if (v instanceof Boolean b) return b;
        return "true".equalsIgnoreCase(String.valueOf(v));
    }

    private static String str(Object o) {
        return o == null ? null : String.valueOf(o);
    }

    private static int intOr0(Object o) {
        if (o instanceof Number n) return n.intValue();
        try {
            return Integer.parseInt(String.valueOf(o));
        } catch (Exception ignore) {
            return 0;
        }
    }

    private static double numberOr0(Object o) {
        if (o instanceof Number n) return n.doubleValue();
        try {
            return Double.parseDouble(String.valueOf(o));
        } catch (Exception ignore) {
            return 0d;
        }
    }
}
