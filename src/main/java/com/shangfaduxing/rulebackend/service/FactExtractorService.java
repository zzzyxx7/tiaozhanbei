package com.shangfaduxing.rulebackend.service;

import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class FactExtractorService {
    private static final String CAUSE_DIVORCE = "divorce_property";
    private static final String CAUSE_UNPAID = "labor_unpaid_wages";
    private static final String CAUSE_NO_CONTRACT = "labor_no_contract";
    private static final String CAUSE_BETROTHAL = "betrothal_property";
    private static final String CAUSE_DIVORCE_GENERAL = "divorce_dispute";
    private static final String CAUSE_POST_DIVORCE = "post_divorce_property";
    private static final String CAUSE_LABOR_INJURY = "labor_injury_compensation";
    private static final String CAUSE_LABOR_OVERTIME = "labor_overtime_pay";

    public Map<String, Object> extractByCause(String causeCode, Map<String, Object> answers) {
        if (CAUSE_DIVORCE.equals(causeCode)) {
            return extractDivorceFacts(answers);
        }
        if (CAUSE_UNPAID.equals(causeCode)) {
            return extractLaborUnpaid(answers);
        }
        if (CAUSE_NO_CONTRACT.equals(causeCode)) {
            return extractLaborNoContract(answers);
        }
        if (CAUSE_BETROTHAL.equals(causeCode)) {
            return extractBetrothal(answers);
        }
        if (CAUSE_DIVORCE_GENERAL.equals(causeCode)) {
            return extractDivorceGeneral(answers);
        }
        if (CAUSE_POST_DIVORCE.equals(causeCode)) {
            return extractPostDivorce(answers);
        }
        if (CAUSE_LABOR_INJURY.equals(causeCode)) {
            return extractLaborInjury(answers);
        }
        if (CAUSE_LABOR_OVERTIME.equals(causeCode)) {
            return extractLaborOvertime(answers);
        }
        return extractLaborTermination(answers);
    }

    private Map<String, Object> extractBetrothal(Map<String, Object> answers) {
        Map<String, Object> facts = new LinkedHashMap<>();
        Map<String, Object> safeAnswers = answers == null ? Map.of() : answers;
        putB(facts, safeAnswers, "存在彩礼给付");
        putB(facts, safeAnswers, "未办理结婚登记");
        putB(facts, safeAnswers, "已办理结婚登记");
        putB(facts, safeAnswers, "已登记后共同生活");
        putB(facts, safeAnswers, "共同生活时间较短");
        putB(facts, safeAnswers, "给付导致生活困难");
        putB(facts, safeAnswers, "对方存在重大过错");
        putB(facts, safeAnswers, "存在法定返还情形");
        facts.put("彩礼金额", numberOr0(safeAnswers.get("彩礼金额")));
        facts.put("共同生活月数", intOr0(safeAnswers.get("共同生活月数")));
        return facts;
    }

    private Map<String, Object> extractDivorceGeneral(Map<String, Object> answers) {
        Map<String, Object> facts = new LinkedHashMap<>();
        Map<String, Object> safeAnswers = answers == null ? Map.of() : answers;
        putB(facts, safeAnswers, "存在合法婚姻关系");
        putB(facts, safeAnswers, "感情确已破裂");
        putB(facts, safeAnswers, "分居满一年");
        putB(facts, safeAnswers, "存在调解意愿");
        putB(facts, safeAnswers, "涉及子女抚养");
        putB(facts, safeAnswers, "子女长期随一方生活");
        putB(facts, safeAnswers, "另一方存在不利抚养因素");
        putB(facts, safeAnswers, "涉及夫妻共同财产");
        putB(facts, safeAnswers, "共同财产范围清晰");
        putB(facts, safeAnswers, "存在共同债务");
        putB(facts, safeAnswers, "存在家庭暴力或重大过错");
        return facts;
    }

    private Map<String, Object> extractPostDivorce(Map<String, Object> answers) {
        Map<String, Object> facts = new LinkedHashMap<>();
        Map<String, Object> safeAnswers = answers == null ? Map.of() : answers;
        putB(facts, safeAnswers, "离婚事实已生效");
        putB(facts, safeAnswers, "存在离婚协议");
        putB(facts, safeAnswers, "离婚协议财产条款未履行");
        putB(facts, safeAnswers, "存在未分割共同财产");
        putB(facts, safeAnswers, "新发现财产线索");
        putB(facts, safeAnswers, "存在隐藏转移财产线索");
        putB(facts, safeAnswers, "有证据证明隐藏转移");
        putB(facts, safeAnswers, "请求再次分割");
        putB(facts, safeAnswers, "请求执行离婚协议");
        return facts;
    }

    private Map<String, Object> extractLaborInjury(Map<String, Object> answers) {
        Map<String, Object> facts = new LinkedHashMap<>();
        Map<String, Object> safeAnswers = answers == null ? Map.of() : answers;
        putB(facts, safeAnswers, "存在劳动关系");
        putB(facts, safeAnswers, "发生工作时间工作场所事故");
        putB(facts, safeAnswers, "已申请或拟申请工伤认定");
        putB(facts, safeAnswers, "存在医疗费用支出");
        putB(facts, safeAnswers, "存在停工留薪损失");
        putB(facts, safeAnswers, "已认定伤残等级");
        putB(facts, safeAnswers, "单位已缴纳工伤保险");
        putB(facts, safeAnswers, "单位拒绝支付工伤待遇");
        return facts;
    }

    private Map<String, Object> extractLaborOvertime(Map<String, Object> answers) {
        Map<String, Object> facts = new LinkedHashMap<>();
        Map<String, Object> safeAnswers = answers == null ? Map.of() : answers;
        putB(facts, safeAnswers, "存在劳动关系");
        putB(facts, safeAnswers, "主张加班费");
        putB(facts, safeAnswers, "存在加班事实");
        putB(facts, safeAnswers, "有加班证据");
        putB(facts, safeAnswers, "存在工作日延时加班");
        putB(facts, safeAnswers, "存在休息日加班");
        putB(facts, safeAnswers, "休息日未安排补休");
        putB(facts, safeAnswers, "存在法定节假日加班");
        putB(facts, safeAnswers, "单位未足额支付加班费");
        facts.put("月均加班时长", intOr0(safeAnswers.get("月均加班时长")));
        return facts;
    }

    private Map<String, Object> extractDivorceFacts(Map<String, Object> answers) {
        Map<String, Object> facts = new LinkedHashMap<>();
        Map<String, Object> safeAnswers = answers == null ? Map.of() : answers;

        facts.put("存在合法婚姻关系", isTrue(safeAnswers.get("存在合法婚姻关系")));
        facts.put("婚姻关系已经解除或正在解除", isTrue(safeAnswers.get("婚姻关系已经解除或正在解除")));
        facts.put("存在房产分割争议", isTrue(safeAnswers.get("存在房产分割争议")));

        facts.put("房产购置时间_婚前", "婚前".equals(str(safeAnswers.get("房产购置时间"))));
        facts.put("房产购置时间_婚后", "婚后".equals(str(safeAnswers.get("房产购置时间"))));
        facts.put("出资主体_一方个人", "一方个人".equals(str(safeAnswers.get("房产出资主体"))));
        facts.put("出资主体_双方共同", "双方共同".equals(str(safeAnswers.get("房产出资主体"))));
        facts.put("出资主体_父母出资", "父母出资".equals(str(safeAnswers.get("房产出资主体"))) || "双方父母".equals(str(safeAnswers.get("房产出资主体"))));
        facts.put("出资性质_全款", "全款".equals(str(safeAnswers.get("房产出资性质"))));
        facts.put("出资性质_按揭", "按揭".equals(str(safeAnswers.get("房产出资性质"))));
        facts.put("登记_出资方个人", "出资方个人".equals(str(safeAnswers.get("产权登记主体"))));
        facts.put("登记_配偶", "配偶".equals(str(safeAnswers.get("产权登记主体"))));
        facts.put("登记_双方共同", "双方共同".equals(str(safeAnswers.get("产权登记主体"))));
        facts.put("登记_父母名下", "父母名下".equals(str(safeAnswers.get("产权登记主体"))));
        facts.put("婚后共同还贷", isTrue(safeAnswers.get("婚后共同还贷")));
        facts.put("增值_自然增值", "自然增值".equals(str(safeAnswers.get("房产增值类型"))));
        facts.put("增值_投资收益", "投资收益".equals(str(safeAnswers.get("房产增值类型"))));

        facts.put("签订离婚协议", isTrue(safeAnswers.get("签订离婚协议")));
        facts.put("协议约定房产分割", isTrue(safeAnswers.get("协议约定房产分割")));
        facts.put("存在房产赠与约定", isTrue(safeAnswers.get("存在房产赠与约定")));
        facts.put("赠与_未过户", "未过户".equals(str(safeAnswers.get("赠与完成过户"))));
        facts.put("赠与_已过户", "已过户".equals(str(safeAnswers.get("赠与完成过户"))));
        facts.put("赠与房产为彩礼", isTrue(safeAnswers.get("赠与房产认定为彩礼")));
        facts.put("双方已办结婚登记", isTrue(safeAnswers.get("双方已办结婚登记")));
        facts.put("登记后共同生活", isTrue(safeAnswers.get("登记后共同生活")));
        facts.put("婚前给付致生活困难", isTrue(safeAnswers.get("婚前给付导致生活困难")));
        facts.put("存在赠与撤销法定情形", isTrue(safeAnswers.get("存在赠与撤销法定情形")));

        facts.put("父母出资_婚前", "婚前".equals(str(safeAnswers.get("父母出资时间"))));
        facts.put("父母出资_婚后", "婚后".equals(str(safeAnswers.get("父母出资时间"))));
        facts.put("父母出资_全额", "全额".equals(str(safeAnswers.get("父母出资比例"))));
        facts.put("父母出资_部分", "部分".equals(str(safeAnswers.get("父母出资比例"))));
        facts.put("存在书面赠与合同", isTrue(safeAnswers.get("存在书面赠与合同")));
        facts.put("赠与合同归己方子女", isTrue(safeAnswers.get("赠与合同归己方子女")));
        facts.put("赠与合同赠与双方", isTrue(safeAnswers.get("赠与合同赠与双方")));

        facts.put("婚姻存续时长", intOr0(safeAnswers.get("婚姻存续时长")));
        String fault = str(safeAnswers.get("存在过错情形"));
        facts.put("存在过错情形", fault != null && !fault.isBlank() && !"无".equals(fault));
        facts.put("过错类型", (fault == null || fault.isBlank()) ? "无" : fault);
        facts.put("过错有充分证据", isTrue(safeAnswers.get("过错有充分证据")));
        facts.put("主张方为无过错方", isTrue(safeAnswers.get("主张方为无过错方")));
        facts.put("存在财产处置不当行为", isTrue(safeAnswers.get("存在财产处置不当行为")));
        facts.put("存在家务劳动超额负担", isTrue(safeAnswers.get("存在家务劳动超额负担")));
        facts.put("无过错方丧失居住权", isTrue(safeAnswers.get("无过错方丧失居住权")));

        facts.put("婚前承租婚后购买公房", isTrue(safeAnswers.get("婚前承租婚后购买公房")));
        facts.put("父母名义房改房", isTrue(safeAnswers.get("父母名义房改房")));

        facts.put("双方对房屋价值归属无法协议", isTrue(safeAnswers.get("双方对房屋价值归属无法协议")));
        facts.put("房屋处置意愿", str(safeAnswers.get("房屋处置意愿")) == null ? "" : str(safeAnswers.get("房屋处置意愿")));
        return facts;
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
