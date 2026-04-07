package com.shangfaduxing.rulebackend.service;

import com.shangfaduxing.rulebackend.model.*;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class CauseRuleService {

    private static final String CAUSE_UNPAID = "labor_unpaid_wages";
    private static final String CAUSE_NO_CONTRACT = "labor_no_contract";
    private static final String CAUSE_ILLEGAL_TERMINATION = "labor_illegal_termination";

    // Legacy in-code asset definitions are kept for reference only and are no longer used at runtime.
    private final Map<String, List<Map<String, Object>>> questionnaireByCause = new HashMap<>();
    private final Map<String, List<Law>> lawsByCause = new HashMap<>();
    private final Map<String, List<TargetDef>> targetsByCause = new HashMap<>();

    private final CauseAssetDbService causeAssetDbService;

    public CauseRuleService(CauseAssetDbService causeAssetDbService) {
        this.causeAssetDbService = causeAssetDbService;
    }

    public boolean supports(String causeCode) {
        return causeAssetDbService.supports(causeCode);
    }

    public List<Map<String, Object>> getQuestionGroups(String causeCode) {
        return causeAssetDbService.getQuestionGroups(causeCode);
    }

    public JudgeResponse judgeByCause(String causeCode, Map<String, Object> answers) {
        if (!supports(causeCode)) return null;
        if (CAUSE_UNPAID.equals(causeCode)) return judgeUnpaidWages(answers);
        if (CAUSE_NO_CONTRACT.equals(causeCode)) return judgeNoContract(answers);
        return judgeIllegalTermination(answers);
    }

    public Step2PlanResponse buildStep2PlanByCause(String causeCode, Map<String, Object> answers, String targetId) {
        Map<String, Object> facts = extractFactsByCause(causeCode, answers);
        List<CauseAssetDbService.TargetDef> targets = causeAssetDbService.getTargetsByCause(causeCode);
        CauseAssetDbService.TargetDef target = targets.stream().filter(t -> Objects.equals(t.targetId, targetId)).findFirst().orElse(targets.isEmpty() ? null : targets.get(0));
        Step2PlanResponse resp = new Step2PlanResponse();
        if (target == null) {
            resp.setSuccess(false);
            resp.setMessage("未找到对应目标");
            resp.setTargetId(targetId);
            resp.setLegalBasis(List.of());
            resp.setFactChecklist(List.of());
            resp.setEvidenceChecklist(List.of());
            return resp;
        }
        List<Law> legalBasis = causeAssetDbService.getLawsByCause(causeCode).stream()
                .filter(l -> target.legalRefs.contains(l.getId()))
                .collect(Collectors.toList());
        List<Step2FactChecklistItem> factChecklist = new ArrayList<>();
        List<Step2EvidenceChecklistItem> evidenceChecklist = new ArrayList<>();
        for (CauseAssetDbService.RequiredFactDef f : target.requiredFacts) {
            boolean proved = Boolean.TRUE.equals(facts.get(f.key));
            factChecklist.add(new Step2FactChecklistItem(f.key, f.label, proved ? "proved" : "unproved"));
            if (!proved) {
                evidenceChecklist.add(new Step2EvidenceChecklistItem(
                        f.key,
                        f.label,
                        target.evidenceMap.getOrDefault(f.key, List.of("其他可证明材料")),
                        true
                ));
            }
        }
        resp.setSuccess(true);
        resp.setMessage("证据指引生成完成");
        resp.setTargetId(target.targetId);
        resp.setTargetTitle(target.title);
        resp.setTargetDesc(target.desc);
        resp.setLegalBasis(legalBasis);
        resp.setFactChecklist(factChecklist);
        resp.setEvidenceChecklist(evidenceChecklist);
        return resp;
    }

    private JudgeResponse judgeUnpaidWages(Map<String, Object> answers) {
        Map<String, Object> facts = extractFactsByCause(CAUSE_UNPAID, answers);
        boolean pre = t(facts, "存在劳动关系") && t(facts, "已提供劳动") && t(facts, "存在欠薪");
        if (!pre) {
            return fail("不满足拖欠工资纠纷的前置条件", "需同时满足：存在劳动关系、已提供劳动、存在欠薪。", facts, CAUSE_UNPAID, answers);
        }
        List<ActivatedPath> paths = new ArrayList<>();
        List<Conclusion> conclusions = new ArrayList<>();
        List<FinalResultItem> finals = new ArrayList<>();
        Set<String> lawRefs = new LinkedHashSet<>();

        boolean evidenceStrong = t(facts, "有工资约定依据") || t(facts, "有考勤或工作记录") || t(facts, "有工资支付记录") || t(facts, "单位书面承认欠薪");
        boolean evidenceMedium = t(facts, "有催要工资记录") || t(facts, "有明确工资周期约定");
        if (evidenceStrong) {
            paths.add(new ActivatedPath("拖欠工资核心事实成立", List.of("存在劳动关系=是", "已提供劳动=是", "存在欠薪=是", "存在核心证据之一=是"), "与+或", "law_contract_30"));
            conclusions.add(new Conclusion("labor_payment", "欠薪请求具有较高支持可能性", "已具备劳动关系、劳动提供、欠薪事实及核心证据链。", List.of("law_labor_50", "law_contract_30", "law_contract_85"), "important"));
            finals.add(new FinalResultItem("欠薪支付请求", "可优先主张足额支付拖欠工资", "建议申请劳动仲裁并提交劳动关系、劳动提供、欠薪金额及催要记录等证据。"));
            lawRefs.addAll(List.of("law_labor_50", "law_contract_30", "law_contract_85"));
        } else if (evidenceMedium) {
            conclusions.add(new Conclusion("labor_payment", "欠薪主张具备一定基础，但仍需补强核心证据", "已有催要记录或工资周期约定，但劳动提供与工资发放链条仍需强化。", List.of("law_labor_50", "law_contract_30"), "warning"));
            finals.add(new FinalResultItem("欠薪支付请求", "可主张，建议先补齐核心证据", "建议补齐工资条、银行流水、考勤记录后再进入仲裁程序。"));
            lawRefs.addAll(List.of("law_labor_50", "law_contract_30"));
        } else {
            conclusions.add(new Conclusion("labor_payment", "欠薪主张存在证据不足风险", "工资约定依据、工作记录或单位承认材料不足。", List.of("law_contract_30"), "warning"));
            finals.add(new FinalResultItem("欠薪支付请求", "可主张，但需补强证据", "请补充劳动合同、工资条、考勤记录、催要沟通记录等关键证据。"));
            lawRefs.add("law_contract_30");
        }

        if (t(facts, "主张加班费") && t(facts, "有加班事实证据") && t(facts, "有加班工资约定依据")) {
            paths.add(new ActivatedPath("加班费请求要件路径命中", List.of("主张加班费=是", "有加班事实证据=是", "有加班工资约定依据=是"), "与", "law_contract_30"));
            conclusions.add(new Conclusion("labor_payment", "加班费请求具备基础支持条件", "已明确加班请求，且有加班事实证据及计算依据。", List.of("law_contract_30"), "important"));
            finals.add(new FinalResultItem("加班费请求", "可一并主张", "建议按工作日/休息日/法定节假日分开整理加班证据并核算金额。"));
            lawRefs.add("law_contract_30");
        }
        if (t(facts, "主张解除补偿") && t(facts, "存在欠薪") && t(facts, "解除原因偏向单位责任")) {
            paths.add(new ActivatedPath("欠薪解除补偿路径命中", List.of("主张解除补偿=是", "存在欠薪=是", "解除原因偏向单位责任=是"), "与", "law_contract_85"));
            conclusions.add(new Conclusion("labor_contract", "解除补偿请求有一定支持可能", "存在欠薪，且解除原因与单位违约行为相关。", List.of("law_contract_85"), "important"));
            finals.add(new FinalResultItem("解除补偿请求", "可结合欠薪事实一并主张", "建议保留解除前催告记录与解除通知，形成完整时间线。"));
            lawRefs.add("law_contract_85");
        }
        if (t(facts, "已向劳动监察投诉") && t(facts, "单位逾期仍未支付")) {
            paths.add(new ActivatedPath("欠薪逾期支付路径命中", List.of("存在欠薪=是", "已投诉/催告=是", "单位逾期仍未支付=是"), "与", "law_contract_85"));
            conclusions.add(new Conclusion("labor_payment", "可进一步主张逾期支付加付赔偿金", "欠薪在投诉/催告后仍未改正，符合加付赔偿金主张方向。", List.of("law_contract_85", "law_reg_16"), "important"));
            finals.add(new FinalResultItem("加付赔偿金请求", "具备主张基础", "建议提交投诉回执、限期支付通知及逾期未支付证明材料。"));
            lawRefs.addAll(List.of("law_contract_85", "law_reg_16"));
        }
        return ok("拖欠工资纠纷推理完成", answers, facts, paths, conclusions, finals, CAUSE_UNPAID, lawRefs);
    }

    private JudgeResponse judgeNoContract(Map<String, Object> answers) {
        Map<String, Object> facts = extractFactsByCause(CAUSE_NO_CONTRACT, answers);
        if (!(t(facts, "存在劳动关系") && t(facts, "未签书面劳动合同"))) {
            return fail("不满足未签劳动合同纠纷的前置条件", "需同时满足：存在劳动关系、未签书面劳动合同。", facts, CAUSE_NO_CONTRACT, answers);
        }
        List<ActivatedPath> paths = new ArrayList<>();
        List<Conclusion> conclusions = new ArrayList<>();
        List<FinalResultItem> finals = new ArrayList<>();
        Set<String> lawRefs = new LinkedHashSet<>();

        boolean canClaimDouble = n(facts, "入职月数") > 1 && !t(facts, "已补签劳动合同") && t(facts, "有工资支付记录");
        if (canClaimDouble) {
            paths.add(new ActivatedPath("未签合同双倍工资要件成立", List.of("存在劳动关系=是", "未签书面劳动合同=是", "超过1个月仍未签=是", "有工资支付记录=是"), "与", "law_contract_82"));
            conclusions.add(new Conclusion("labor_contract", "可主张未签书面劳动合同期间双倍工资", "入职超过一个月未签劳动合同且有工资支付事实支持。", List.of("law_contract_10", "law_contract_82"), "important"));
            finals.add(new FinalResultItem("双倍工资请求", "可主张（符合法定要件）", "建议按入职时间线整理证据，核算可主张区间后通过劳动仲裁主张。"));
            lawRefs.addAll(List.of("law_contract_10", "law_contract_82"));
        } else {
            conclusions.add(new Conclusion("labor_contract", "双倍工资请求存在要件不足", "可能未满足“超过一个月仍未签”或关键证据不足。", List.of("law_contract_10", "law_contract_82"), "warning"));
            finals.add(new FinalResultItem("双倍工资请求", "暂不稳妥", "建议补充入职时间、工资支付、管理从属性证据后再评估。"));
            lawRefs.addAll(List.of("law_contract_10", "law_contract_82"));
        }
        if (t(facts, "主张补签书面合同") && t(facts, "未签书面劳动合同")) {
            paths.add(new ActivatedPath("补签劳动合同请求路径命中", List.of("存在劳动关系=是", "未签书面劳动合同=是", "主张补签合同=是"), "与", "law_contract_10"));
            conclusions.add(new Conclusion("labor_contract", "可请求单位补签书面劳动合同", "劳动关系存续且未签书面合同，补签请求具有正当性。", List.of("law_contract_10"), "important"));
            finals.add(new FinalResultItem("补签劳动合同请求", "可主张", "建议先发出书面补签申请并保留送达凭证。"));
            lawRefs.add("law_contract_10");
        }
        if (t(facts, "主张无固定期限合同")) {
            if (t(facts, "满足无固定期限条件")) {
                conclusions.add(new Conclusion("labor_contract", "无固定期限合同请求有支持可能", "已明确主张且满足法定条件。", List.of("law_contract_14"), "important"));
                finals.add(new FinalResultItem("无固定期限合同请求", "可主张", "建议提交工龄、续签记录等证明满足法定条件。"));
                lawRefs.add("law_contract_14");
            } else {
                conclusions.add(new Conclusion("labor_contract", "无固定期限合同请求要件不足", "目前尚未证明满足法定条件。", List.of("law_contract_14"), "warning"));
                lawRefs.add("law_contract_14");
            }
        }
        if (t(facts, "单位拒绝签合同")) {
            paths.add(new ActivatedPath("单位拒绝签约事实路径命中", List.of("未签书面劳动合同=是", "单位拒绝签合同=是"), "与", "law_contract_10"));
            conclusions.add(new Conclusion("labor_contract", "可强调单位主观拒签责任", "存在单位拒签沟通记录，可强化双倍工资主张说服力。", List.of("law_contract_10", "law_contract_82"), "important"));
            lawRefs.addAll(List.of("law_contract_10", "law_contract_82"));
        }
        return ok("未签劳动合同纠纷推理完成", answers, facts, paths, conclusions, finals, CAUSE_NO_CONTRACT, lawRefs);
    }

    private JudgeResponse judgeIllegalTermination(Map<String, Object> answers) {
        Map<String, Object> facts = extractFactsByCause(CAUSE_ILLEGAL_TERMINATION, answers);
        if (!(t(facts, "存在劳动关系") && t(facts, "已被解除或辞退"))) {
            return fail("不满足违法解除劳动关系纠纷的前置条件", "需同时满足：存在劳动关系，且已发生解除/辞退。", facts, CAUSE_ILLEGAL_TERMINATION, answers);
        }
        List<ActivatedPath> paths = new ArrayList<>();
        List<Conclusion> conclusions = new ArrayList<>();
        List<FinalResultItem> finals = new ArrayList<>();
        Set<String> lawRefs = new LinkedHashSet<>();

        boolean illegalLikely =
                t(facts, "解除理由不明确")
                        || (t(facts, "有解除通知") && !t(facts, "解除通知为书面"))
                        || (t(facts, "解除理由_40") && !t(facts, "提前30日通知或支付代通知金"))
                        || (t(facts, "解除理由_39") && (!t(facts, "单位有严重违纪证据") || !t(facts, "规章制度已公示且合法")))
                        || (t(facts, "解除理由_41") && !t(facts, "经济性裁员符合法定人数与报告程序"))
                        || !t(facts, "单位是否履行工会程序")
                        || t(facts, "处于特殊保护期");
        facts.put("解除程序或理由存在瑕疵", illegalLikely);

        if (illegalLikely) {
            paths.add(new ActivatedPath("违法解除判断路径命中", List.of("存在劳动关系=是", "已被解除或辞退=是", "理由或程序存在违法瑕疵=是"), "与/或", "law_contract_48"));
            conclusions.add(new Conclusion("labor_termination", "解除行为存在较高概率被认定为违法", "解除理由或程序不符合法定要求，或存在特殊保护期内解除风险。", List.of("law_contract_39", "law_contract_40", "law_contract_41", "law_contract_48", "law_contract_87"), "important"));
            finals.add(new FinalResultItem("违法解除判断", "可优先主张认定为违法解除", "建议围绕解除理由合法性、解除程序合法性、特殊保护期事实整理证据。"));
            lawRefs.addAll(List.of("law_contract_39", "law_contract_40", "law_contract_41", "law_contract_48", "law_contract_87"));
        } else {
            conclusions.add(new Conclusion("labor_termination", "目前证据显示解除较可能符合法定情形", "解除理由类型指向法定条款且程序上未见明显违法点。", List.of("law_contract_39", "law_contract_40", "law_contract_41"), "warning"));
            finals.add(new FinalResultItem("违法解除判断", "暂无充分依据支持违法解除", "可补充解除通知、规章制度公示、工会意见、保护期证明等材料后再评估。"));
            lawRefs.addAll(List.of("law_contract_39", "law_contract_40", "law_contract_41"));
        }
        if (!t(facts, "单位是否履行工会程序")) {
            conclusions.add(new Conclusion("labor_termination", "解除程序存在工会程序瑕疵风险", "单位未充分履行工会程序，程序合法性存在明显争议点。", List.of("law_contract_41", "law_contract_48"), "warning"));
            lawRefs.addAll(List.of("law_contract_41", "law_contract_48"));
        }
        if (t(facts, "解除理由_41") && !t(facts, "经济性裁员符合法定人数与报告程序")) {
            paths.add(new ActivatedPath("第41条裁员程序不足路径命中", List.of("解除理由=第41条", "未满足法定人数或报告程序"), "与", "law_contract_41"));
            conclusions.add(new Conclusion("labor_termination", "经济性裁员程序合法性不足", "经济性裁员未充分体现法定人数或报告程序要求。", List.of("law_contract_41", "law_contract_48"), "warning"));
            lawRefs.addAll(List.of("law_contract_41", "law_contract_48"));
        }
        if (t(facts, "主张继续履行劳动合同")) {
            finals.add(new FinalResultItem("诉请方向", "可请求继续履行劳动合同", "如劳动者主张继续履行且用人单位仍可继续履行，可作为主要请求。"));
        }
        if (t(facts, "主张停工期间工资损失")) {
            finals.add(new FinalResultItem("诉请方向", "可主张停工期间工资损失", "建议结合停工期间证据材料核算损失并一并主张。"));
        }
        return ok("违法解除劳动关系纠纷推理完成", answers, facts, paths, conclusions, finals, CAUSE_ILLEGAL_TERMINATION, lawRefs);
    }

    private Map<String, Object> extractFactsByCause(String causeCode, Map<String, Object> answers) {
        Map<String, Object> facts = new LinkedHashMap<>();
        Map<String, Object> safeAnswers = answers == null ? Map.of() : answers;
        if (CAUSE_UNPAID.equals(causeCode)) {
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
        if (CAUSE_NO_CONTRACT.equals(causeCode)) {
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

    @SuppressWarnings("unused")
    private void initUnpaidWages() {
        lawsByCause.put(CAUSE_UNPAID, List.of(
                law("law_labor_50", "中华人民共和国劳动法", "第五十条", "工资应当按月支付", "工资应当以货币形式按月支付给劳动者本人，不得克扣或者无故拖欠劳动者的工资。"),
                law("law_contract_30", "中华人民共和国劳动合同法", "第三十条", "按约足额支付劳动报酬", "用人单位应当按照劳动合同约定和国家规定，向劳动者及时足额支付劳动报酬。"),
                law("law_contract_85", "中华人民共和国劳动合同法", "第八十五条", "未按约支付劳动报酬责任", "用人单位未及时足额支付劳动报酬的，由劳动行政部门责令限期支付；逾期不支付的，可责令加付赔偿金。"),
                law("law_reg_16", "工资支付暂行规定", "第十六条", "克扣、拖欠工资处理", "用人单位不得克扣劳动者工资；无故拖欠劳动者工资的，应依法承担责任。")
        ));
        targetsByCause.put(CAUSE_UNPAID, List.of(
                target("target_labor_unpaid_wages_full_payment", "争取尽快足额支付欠薪", "重点证成劳动关系、实际劳动及欠薪事实，并补强金额依据。",
                        List.of("law_labor_50", "law_contract_30", "law_contract_85", "law_reg_16"),
                        List.of(rf("存在劳动关系", "与单位存在劳动关系"), rf("已提供劳动", "已经实际提供劳动"), rf("存在欠薪", "存在拖欠工资事实"), rf("有工资约定依据", "有工资标准/约定依据"), rf("有工资支付记录", "有工资发放/欠发记录"), rf("有催要工资记录", "有催要工资沟通记录"), rf("有明确工资周期约定", "有明确工资发放周期约定")),
                        Map.of("存在劳动关系", List.of("劳动合同", "入职登记信息", "社保缴纳记录"),
                                "已提供劳动", List.of("考勤记录", "工作群记录", "工作成果材料"),
                                "存在欠薪", List.of("工资发放明细", "银行流水"),
                                "有工资约定依据", List.of("劳动合同", "工资条", "薪酬制度文件"),
                                "有工资支付记录", List.of("银行流水", "工资转账记录", "工资条"),
                                "有催要工资记录", List.of("微信聊天记录", "短信记录", "通话录音"),
                                "有明确工资周期约定", List.of("劳动合同条款", "薪资制度文件"))
                ),
                target("target_labor_unpaid_wages_overtime", "一并主张加班费", "在欠薪之外，主张存在加班且未依法支付加班费。",
                        List.of("law_contract_30"),
                        List.of(rf("主张加班费", "明确提出加班费请求"), rf("有加班事实证据", "有加班事实证据"), rf("有加班工资约定依据", "有加班工资计算依据")),
                        Map.of("主张加班费", List.of("仲裁请求清单"), "有加班事实证据", List.of("考勤记录", "加班审批单", "门禁记录"), "有加班工资约定依据", List.of("公司规章制度", "劳动合同条款"))
                ),
                target("target_labor_unpaid_wages_termination_compensation", "争取解除劳动关系并主张经济补偿", "当单位长期欠薪时，考虑依法解除并主张经济补偿。",
                        List.of("law_contract_85"),
                        List.of(rf("主张解除补偿", "明确提出解除补偿请求"), rf("存在欠薪", "存在拖欠工资事实"), rf("解除原因偏向单位责任", "解除原因与单位欠薪行为相关")),
                        Map.of("主张解除补偿", List.of("解除通知", "仲裁请求清单"), "存在欠薪", List.of("银行流水", "工资条"), "解除原因偏向单位责任", List.of("催告记录", "解除沟通记录"))
                ),
                target("target_labor_unpaid_wages_additional_compensation", "争取逾期支付加付赔偿金", "针对欠薪且经催告/责令后仍不支付的情形，主张加付赔偿金。",
                        List.of("law_contract_85", "law_reg_16"),
                        List.of(rf("存在欠薪", "存在拖欠工资事实"), rf("已向劳动监察投诉", "已向劳动监察投诉或正式催告"), rf("单位逾期仍未支付", "单位逾期仍未支付")),
                        Map.of("存在欠薪", List.of("工资条", "银行流水"), "已向劳动监察投诉", List.of("投诉回执", "受理通知"), "单位逾期仍未支付", List.of("限期支付通知", "逾期未支付证明"))
                )
        ));
        questionnaireByCause.put(CAUSE_UNPAID, List.of(group("LW0", "前置事实确认", "先确认是否属于拖欠工资纠纷的基本前提",
                        List.of(q("存在劳动关系", "你与单位之间是否存在劳动关系？", "boolean", true, null, null),
                                q("已提供劳动", "你是否已经实际提供劳动？", "boolean", true, null, null),
                                q("存在欠薪", "单位是否存在拖欠工资的情形？", "boolean", true, null, null))),
                group("LW1", "劳动关系与工资约定", "先把劳动关系和工资标准证据补齐",
                        List.of(q("入职时间已明确", "你的入职时间是否可以明确到年月？", "boolean", false, null, null),
                                q("离职时间已明确", "如已离职，离职时间是否可以明确到年月？", "boolean", false, null, null),
                                q("欠薪金额", "拖欠工资金额大约是多少？", "number", false, null, "元"),
                                q("欠薪时长", "拖欠工资已持续多久？", "number", false, null, "个月"),
                                q("有工资约定依据", "是否有劳动合同/工资条等工资约定依据？", "boolean", false, null, null),
                                q("有考勤或工作记录", "是否有考勤记录、工作群记录、工作成果等劳动证据？", "boolean", false, null, null),
                                q("有工资支付记录", "是否有银行流水/工资发放记录？", "boolean", false, null, null),
                                q("有催要工资记录", "是否有催要工资的聊天记录/短信/录音？", "boolean", false, null, null),
                                q("单位书面承认欠薪", "单位是否有书面承认欠薪的材料？", "boolean", false, null, null),
                                q("有明确工资周期约定", "是否有明确工资发放周期约定（按月/按周）？", "boolean", false, null, null))),
                group("LW2", "延伸请求（可选）", "如需主张加班费或解除补偿，补充对应事实",
                        List.of(q("主张加班费", "你是否希望一并主张加班费？", "boolean", false, null, null),
                                q("有加班事实证据", "是否有加班记录（考勤、审批、聊天等）？", "boolean", false, condition("主张加班费", true), null),
                                q("有加班工资约定依据", "是否有加班工资计算依据（制度/约定）？", "boolean", false, condition("主张加班费", true), null),
                                q("主张解除补偿", "你是否希望主张解除劳动关系经济补偿？", "boolean", false, null, null),
                                q("解除原因偏向单位责任", "解除劳动关系是否主要因单位未及时足额支付劳动报酬？", "boolean", false, condition("主张解除补偿", true), null),
                                q("已向劳动监察投诉", "是否已向劳动监察部门投诉欠薪？", "boolean", false, null, null),
                                q("单位逾期仍未支付", "在催告或责令后单位是否逾期仍未支付？", "boolean", false, null, null)))));
    }

    @SuppressWarnings("unused")
    private void initNoContract() {
        lawsByCause.put(CAUSE_NO_CONTRACT, List.of(
                law("law_contract_10", "中华人民共和国劳动合同法", "第十条", "建立劳动关系应订立书面劳动合同", "建立劳动关系，应当订立书面劳动合同。"),
                law("law_contract_82", "中华人民共和国劳动合同法", "第八十二条", "未签书面劳动合同双倍工资", "超过一个月未签书面劳动合同的，应当支付二倍工资。"),
                law("law_contract_14", "中华人民共和国劳动合同法", "第十四条", "无固定期限劳动合同情形", "符合连续订立合同等法定条件的，可要求无固定期限劳动合同。")
        ));
        targetsByCause.put(CAUSE_NO_CONTRACT, List.of(
                target("target_labor_no_contract_double_wage", "争取未签合同期间双倍工资", "重点证明劳动关系成立、未签合同持续时间及工资支付事实。",
                        List.of("law_contract_10", "law_contract_82"),
                        List.of(rf("存在劳动关系", "与单位存在劳动关系"), rf("未签书面劳动合同", "超过一个月未签书面劳动合同"), rf("有工资支付记录", "存在工资发放事实")),
                        Map.of("存在劳动关系", List.of("考勤记录", "工作安排聊天记录"), "未签书面劳动合同", List.of("合同缺失说明", "沟通记录"), "有工资支付记录", List.of("银行流水", "工资条"))),
                target("target_labor_no_contract_sign_contract", "请求补签书面劳动合同", "在劳动关系持续期间，要求单位补签书面劳动合同。",
                        List.of("law_contract_10"),
                        List.of(rf("存在劳动关系", "与单位存在劳动关系"), rf("未签书面劳动合同", "尚未签订书面劳动合同"), rf("主张补签书面合同", "已明确请求补签合同")),
                        Map.of("存在劳动关系", List.of("考勤记录", "工牌"), "未签书面劳动合同", List.of("合同缺失说明", "入职材料"), "主张补签书面合同", List.of("书面申请", "邮件记录"))),
                target("target_labor_no_contract_open_term", "请求订立无固定期限劳动合同", "符合条件时请求订立无固定期限劳动合同。",
                        List.of("law_contract_14"),
                        List.of(rf("存在劳动关系", "与单位存在劳动关系"), rf("主张无固定期限合同", "已明确主张无固定期限合同"), rf("满足无固定期限条件", "已满足法定条件")),
                        Map.of("存在劳动关系", List.of("劳动关系证明材料"), "主张无固定期限合同", List.of("请求书"), "满足无固定期限条件", List.of("工龄证明", "续签记录")))
        ));
        questionnaireByCause.put(CAUSE_NO_CONTRACT, List.of(group("LN0", "前置事实确认", "确认是否属于未签劳动合同争议",
                        List.of(q("存在劳动关系", "你与单位之间是否存在劳动关系？", "boolean", true, null, null),
                                q("未签书面劳动合同", "你是否未与单位签订书面劳动合同？", "boolean", true, null, null))),
                group("LN1", "关键要件补全", "确认用工时长、补签情况及基础证据",
                        List.of(q("入职月数", "从入职至今共工作了几个月？", "number", false, null, "个月"),
                                q("已补签劳动合同", "后续是否已经补签过劳动合同？", "boolean", false, null, null),
                                q("有工资支付记录", "是否有工资发放记录（转账、工资条等）？", "boolean", false, null, null),
                                q("有工作管理证据", "是否有考勤、工作安排、工牌等管理从属性证据？", "boolean", false, null, null),
                                q("单位拒绝签合同", "是否有单位拒绝签订书面合同的沟通记录？", "boolean", false, null, null))),
                group("LN2", "延伸请求（可选）", "补充无固定期限合同等进阶诉请",
                        List.of(q("主张补签书面合同", "你是否主张补签书面劳动合同？", "boolean", false, null, null),
                                q("主张无固定期限合同", "你是否主张签订无固定期限劳动合同？", "boolean", false, null, null),
                                q("满足无固定期限条件", "你是否已满足无固定期限劳动合同法定条件？", "boolean", false, condition("主张无固定期限合同", true), null)))));
    }

    @SuppressWarnings("unused")
    private void initIllegalTermination() {
        lawsByCause.put(CAUSE_ILLEGAL_TERMINATION, List.of(
                law("law_contract_39", "中华人民共和国劳动合同法", "第三十九条", "过失性解除", "劳动者存在严重违纪等法定情形的，用人单位可以解除劳动合同。"),
                law("law_contract_40", "中华人民共和国劳动合同法", "第四十条", "无过失性解除", "用人单位依据法定事由解除劳动合同的，应提前三十日书面通知或支付代通知金。"),
                law("law_contract_41", "中华人民共和国劳动合同法", "第四十一条", "经济性裁员", "经济性裁员应符合法定人数、程序和报告要求。"),
                law("law_contract_48", "中华人民共和国劳动合同法", "第四十八条", "违法解除后果", "违法解除的，劳动者可请求继续履行劳动合同或者请求赔偿金。"),
                law("law_contract_87", "中华人民共和国劳动合同法", "第八十七条", "违法解除赔偿金", "违法解除劳动合同的，应按经济补偿标准二倍支付赔偿金。")
        ));
        targetsByCause.put(CAUSE_ILLEGAL_TERMINATION, List.of(
                target("target_illegal_termination_compensation", "主张违法解除赔偿金", "重点证明解除缺乏法定事由或程序违法，进而请求二倍赔偿。",
                        List.of("law_contract_48", "law_contract_87", "law_contract_39", "law_contract_40", "law_contract_41"),
                        List.of(rf("存在劳动关系", "与单位存在劳动关系"), rf("已被解除或辞退", "已发生解除/辞退事实"), rf("解除程序或理由存在瑕疵", "解除理由或程序存在违法情形")),
                        Map.of("存在劳动关系", List.of("劳动合同", "社保记录", "工资记录"), "已被解除或辞退", List.of("解除通知书", "辞退聊天记录"), "解除程序或理由存在瑕疵", List.of("解除通知内容", "规章制度", "工会材料"))),
                target("target_illegal_termination_reinstatement", "请求继续履行劳动合同", "在违法解除情形下，优先请求恢复劳动关系并继续履行合同。",
                        List.of("law_contract_48"),
                        List.of(rf("存在劳动关系", "与单位存在劳动关系"), rf("已被解除或辞退", "已发生解除/辞退事实"), rf("主张继续履行劳动合同", "已明确请求恢复劳动关系")),
                        Map.of("存在劳动关系", List.of("劳动合同", "工资流水"), "已被解除或辞退", List.of("解除通知书"), "主张继续履行劳动合同", List.of("仲裁请求书", "复工申请"))),
                target("target_illegal_termination_wage_gap", "主张停工期间工资损失", "在解除违法且未及时恢复岗位时，主张停工待岗期间工资等损失。",
                        List.of("law_contract_48", "law_contract_87"),
                        List.of(rf("存在劳动关系", "与单位存在劳动关系"), rf("已被解除或辞退", "已发生解除/辞退事实"), rf("主张停工期间工资损失", "已明确主张停工期间工资损失")),
                        Map.of("存在劳动关系", List.of("劳动合同", "工资记录"), "已被解除或辞退", List.of("解除通知", "系统停权记录"), "主张停工期间工资损失", List.of("工资标准依据", "历史工资流水"))),
                target("target_illegal_termination_revoke_decision", "确认解除决定违法并撤销", "确认解除决定违法，作为赔偿或恢复劳动关系前置支撑。",
                        List.of("law_contract_39", "law_contract_40", "law_contract_41", "law_contract_48"),
                        List.of(rf("存在劳动关系", "与单位存在劳动关系"), rf("已被解除或辞退", "已发生解除/辞退事实"), rf("解除理由不明确", "解除理由不明确或与法条不匹配"), rf("解除通知为书面", "解除通知书面瑕疵（反向佐证）")),
                        Map.of("存在劳动关系", List.of("劳动合同", "工资流水"), "已被解除或辞退", List.of("解除通知"), "解除理由不明确", List.of("解除通知内容", "单位说明材料"), "解除通知为书面", List.of("书面通知原件", "送达记录")))
        ));
        questionnaireByCause.put(CAUSE_ILLEGAL_TERMINATION, List.of(group("LT0", "前置事实确认", "先确认是否属于违法解除劳动争议",
                        List.of(q("存在劳动关系", "你与单位之间是否存在劳动关系？", "boolean", true, null, null),
                                q("已被解除或辞退", "你是否已被解除劳动合同或辞退？", "boolean", true, null, null))),
                group("LT1", "解除事实", "补充解除通知、解除理由及程序事实",
                        List.of(q("有解除通知", "单位是否向你发出过解除/辞退通知？", "boolean", false, null, null),
                                q("解除通知为书面", "该解除通知是否为书面形式？", "boolean", false, condition("有解除通知", true), null),
                                choice("解除理由类型", "单位主张的解除理由属于哪一类？", false, List.of(
                                        opt("过失性解除（第39条）", "article_39"),
                                        opt("无过失性解除（第40条）", "article_40"),
                                        opt("经济性裁员（第41条）", "article_41"),
                                        opt("无法说明或其他", "unknown")
                                )),
                                q("提前30日通知或支付代通知金", "如属第40条情形，单位是否提前30日书面通知或支付代通知金？", "boolean", false, condition("解除理由类型", "article_40"), null),
                                q("单位是否履行工会程序", "单位解除前是否履行通知工会等程序？", "boolean", false, null, null),
                                q("规章制度已公示且合法", "单位依据的规章制度是否经过民主程序并已公示？", "boolean", false, null, null))),
                group("LT2", "延伸事实", "核对特殊保护期及单位证据情况",
                        List.of(q("处于特殊保护期", "解除时你是否处于医疗期/孕期/工伤停工留薪期等特殊保护期？", "boolean", false, null, null),
                                q("单位有严重违纪证据", "单位是否能提供你严重违纪的明确证据？", "boolean", false, null, null),
                                q("经济性裁员符合法定人数与报告程序", "如属经济性裁员，单位是否满足法定人数与报告程序？", "boolean", false, null, null),
                                q("主张继续履行劳动合同", "你是否希望优先主张恢复劳动关系（继续履行劳动合同）？", "boolean", false, null, null),
                                q("主张停工期间工资损失", "你是否主张停工期间工资损失（或等待恢复期间损失）？", "boolean", false, null, null)))));
    }

    private JudgeResponse fail(String message, String detail, Map<String, Object> facts, String causeCode, Map<String, Object> answers) {
        JudgeResponse resp = new JudgeResponse();
        resp.setSuccess(false);
        resp.setMessage(message);
        resp.setDetail(detail);
        resp.setAnswers(answers);
        resp.setFacts(facts);
        resp.setActivatedPaths(List.of());
        resp.setConclusions(List.of());
        resp.setFinalResults(List.of());
        resp.setLawsApplied(List.of());
        resp.setStep2(buildMeta(causeCode, facts));
        return resp;
    }

    private JudgeResponse ok(String message, Map<String, Object> answers, Map<String, Object> facts,
                             List<ActivatedPath> paths, List<Conclusion> conclusions, List<FinalResultItem> finals,
                             String causeCode, Set<String> lawRefs) {
        JudgeResponse resp = new JudgeResponse();
        resp.setSuccess(true);
        resp.setMessage(message);
        resp.setAnswers(answers);
        resp.setFacts(facts);
        resp.setActivatedPaths(paths);
        resp.setConclusions(conclusions);
        resp.setFinalResults(finals);
        resp.setLawsApplied(causeAssetDbService.getLawsByCause(causeCode).stream().filter(l -> lawRefs.contains(l.getId())).collect(Collectors.toList()));
        resp.setStep2(buildMeta(causeCode, facts));
        return resp;
    }

    private Step2Meta buildMeta(String causeCode, Map<String, Object> facts) {
        List<CauseAssetDbService.TargetDef> defs = causeAssetDbService.getTargetsByCause(causeCode);
        List<Step2TargetMeta> targets = defs.stream().map(d -> new Step2TargetMeta(d.targetId, d.title, d.desc)).collect(Collectors.toList());
        List<String> suggested = defs.stream()
                .filter(d -> {
                    if (d.requiredFacts.isEmpty()) return true;
                    long proved = d.requiredFacts.stream().filter(r -> Boolean.TRUE.equals(facts.get(r.key))).count();
                    return ((double) proved / d.requiredFacts.size()) >= 0.5d;
                })
                .map(d -> d.targetId)
                .collect(Collectors.toList());
        return new Step2Meta(targets, suggested);
    }

    private static Law law(String id, String name, String article, String summary, String text) {
        return new Law(id, name, article, summary, text, "2008-01-01");
    }

    private static RequiredFactDef rf(String key, String label) {
        return new RequiredFactDef(key, label);
    }

    private static TargetDef target(String targetId, String title, String desc, List<String> legalRefs, List<RequiredFactDef> requiredFacts, Map<String, List<String>> evidenceMap) {
        return new TargetDef(targetId, title, desc, legalRefs, requiredFacts, evidenceMap);
    }

    private static Map<String, Object> group(String groupId, String groupName, String groupDesc, List<Map<String, Object>> questions) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("groupId", groupId);
        m.put("groupName", groupName);
        m.put("groupDesc", groupDesc);
        m.put("questions", questions);
        return m;
    }

    private static Map<String, Object> q(String key, String text, String type, boolean required, Map<String, Object> condition, String unit) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("key", key);
        m.put("text", text);
        m.put("type", type);
        m.put("required", required);
        if (condition != null) m.put("condition", condition);
        if (unit != null) m.put("unit", unit);
        return m;
    }

    private static Map<String, Object> choice(String key, String text, boolean required, List<Map<String, Object>> options) {
        Map<String, Object> m = q(key, text, "choice", required, null, null);
        m.put("options", options);
        return m;
    }

    private static Map<String, Object> opt(String label, String value) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("label", label);
        m.put("value", value);
        return m;
    }

    private static Map<String, Object> condition(String key, Object value) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("key", key);
        m.put("value", value);
        return m;
    }

    private static void putB(Map<String, Object> facts, Map<String, Object> answers, String key) {
        facts.put(key, isTrue(answers.get(key)));
    }

    private static boolean isTrue(Object v) {
        if (v instanceof Boolean b) return b;
        return "true".equalsIgnoreCase(String.valueOf(v));
    }

    private static boolean t(Map<String, Object> facts, String key) {
        return Boolean.TRUE.equals(facts.get(key));
    }

    private static int n(Map<String, Object> facts, String key) {
        Object v = facts.get(key);
        return intOr0(v);
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

    @SuppressWarnings("unused")
    private static class TargetDef {
        private final String targetId;
        private final String title;
        private final String desc;
        private final List<String> legalRefs;
        private final List<RequiredFactDef> requiredFacts;
        private final Map<String, List<String>> evidenceMap;

        private TargetDef(String targetId, String title, String desc, List<String> legalRefs, List<RequiredFactDef> requiredFacts, Map<String, List<String>> evidenceMap) {
            this.targetId = targetId;
            this.title = title;
            this.desc = desc;
            this.legalRefs = legalRefs;
            this.requiredFacts = requiredFacts;
            this.evidenceMap = evidenceMap;
        }
    }

    @SuppressWarnings("unused")
    private static class RequiredFactDef {
        private final String key;
        private final String label;

        private RequiredFactDef(String key, String label) {
            this.key = key;
            this.label = label;
        }
    }
}

