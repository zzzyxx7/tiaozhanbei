package com.shangfaduxing.rulebackend.service;

import com.shangfaduxing.rulebackend.model.CauseCategory;
import com.shangfaduxing.rulebackend.model.CauseItem;
import com.shangfaduxing.rulebackend.model.JudgeResponse;
import com.shangfaduxing.rulebackend.model.Step2ActionItem;
import com.shangfaduxing.rulebackend.model.Step2EvidenceHowToItem;
import com.shangfaduxing.rulebackend.model.Step2EvidenceChecklistItem;
import com.shangfaduxing.rulebackend.model.Step2FactChecklistItem;
import com.shangfaduxing.rulebackend.model.Step2FollowupQuestion;
import com.shangfaduxing.rulebackend.model.Step2PlanResponse;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
public class RuleCenterService {

    private static final String CAUSE_DIVORCE = "divorce_property";
    private static final String CAUSE_PROPERTY_DISPUTE = "property_dispute";

    private final CauseAssetDbService causeAssetDbService;
    private final FactExtractorService factExtractorService;
    private final DbRuleExecutorService dbRuleExecutorService;

    public RuleCenterService(
            CauseAssetDbService causeAssetDbService,
            FactExtractorService factExtractorService,
            DbRuleExecutorService dbRuleExecutorService
    ) {
        this.causeAssetDbService = causeAssetDbService;
        this.factExtractorService = factExtractorService;
        this.dbRuleExecutorService = dbRuleExecutorService;
    }

    public JudgeResponse judge(String causeCode, Map<String, Object> answers) {
        String normalized = normalizeCauseCode(causeCode);
        Map<String, Object> facts = factExtractorService.extractByCause(normalized, answers);
        return dbRuleExecutorService.execute(normalized, answers, facts);
    }

    public Step2PlanResponse step2(String causeCode, Map<String, Object> answers, String targetId) {
        String normalized = normalizeCauseCode(causeCode);
        Map<String, Object> facts = factExtractorService.extractByCause(normalized, answers);
        List<CauseAssetDbService.TargetDef> targets = causeAssetDbService.getTargetsByCause(normalized);
        CauseAssetDbService.TargetDef target = targets.stream()
                .filter(t -> Objects.equals(t.targetId, targetId))
                .findFirst()
                .orElse(targets.isEmpty() ? null : targets.get(0));
        Step2PlanResponse resp = new Step2PlanResponse();
        if (target == null) {
            resp.setSuccess(false);
            resp.setMessage("未找到对应目标");
            resp.setTargetId(targetId);
            resp.setLegalBasis(List.of());
            resp.setFactChecklist(List.of());
            resp.setEvidenceChecklist(List.of());
            resp.setActionPlan(List.of());
            resp.setRiskWarnings(List.of("未匹配到可执行目标，请先在 Step2 选择目标后重试。"));
            resp.setHandlingPath(List.of("补全案由目标映射", "补全关键事实", "重新生成 Step2 计划"));
            resp.setTotalFactCount(0);
            resp.setProvedFactCount(0);
            resp.setUnprovedFactCount(0);
            resp.setProveRate(0d);
            return resp;
        }
        List<Step2FactChecklistItem> factChecklist = new ArrayList<>();
        List<Step2EvidenceChecklistItem> evidenceChecklist = new ArrayList<>();
        List<Step2ActionItem> actionPlan = new ArrayList<>();
        int provedCount = 0;
        int unprovedCount = 0;
        int unprovedIndex = 0;
        for (CauseAssetDbService.RequiredFactDef f : target.requiredFacts) {
            boolean proved = Boolean.TRUE.equals(facts.get(f.key));
            factChecklist.add(new Step2FactChecklistItem(f.key, f.label, proved ? "proved" : "unproved"));
            if (proved) {
                provedCount++;
            }
            if (!proved) {
                unprovedCount++;
                unprovedIndex++;
                List<String> evTypes = target.evidenceMap.getOrDefault(f.key, List.of("其他可证明材料"));
                List<Step2EvidenceHowToItem> howTo = buildEvidenceHowTo(normalized, evTypes);
                evidenceChecklist.add(new Step2EvidenceChecklistItem(
                        f.key,
                        f.label,
                        evTypes,
                        howTo,
                        buildFollowupQuestionsForEvidence(normalized, f.key, f.label, evTypes),
                        true
                ));
                actionPlan.add(new Step2ActionItem(
                        f.key,
                        f.label,
                        priorityByIndex(unprovedIndex),
                        "优先把「" + f.label + "」补强为可被采信的已证成事实",
                        evTypes,
                        flattenHowTo(howTo)
                ));
            }
        }
        resp.setSuccess(true);
        resp.setMessage("证据指引生成完成");
        resp.setTargetId(target.targetId);
        resp.setTargetTitle(target.title);
        resp.setTargetDesc(target.desc);
        resp.setLegalBasis(causeAssetDbService.getLawsByCause(normalized).stream()
                .filter(l -> target.legalRefs.contains(l.getId()))
                .collect(Collectors.toList()));
        resp.setFactChecklist(factChecklist);
        resp.setEvidenceChecklist(evidenceChecklist);
        int total = target.requiredFacts == null ? 0 : target.requiredFacts.size();
        resp.setTotalFactCount(total);
        resp.setProvedFactCount(provedCount);
        resp.setUnprovedFactCount(unprovedCount);
        resp.setProveRate(total == 0 ? 1d : round2((double) provedCount / total));
        resp.setActionPlan(actionPlan);
        resp.setRiskWarnings(buildRiskWarnings(normalized, unprovedCount, total));
        resp.setHandlingPath(buildHandlingPath(unprovedCount));
        return resp;
    }

    private List<String> buildRiskWarnings(String causeCode, int unprovedCount, int total) {
        List<String> out = new ArrayList<>();
        if (total > 0 && unprovedCount > 0) {
            out.add("当前仍有 " + unprovedCount + " 项关键事实未证成，可能影响诉请支持度。");
        }
        if (total > 0 && unprovedCount >= Math.max(2, total / 2)) {
            out.add("未证成比例偏高，建议先补证据再提交完整诉请。");
        }
        if (causeAssetDbService.isMarriageFamilyCause(causeCode)) {
            out.add("婚姻家事案件中，转账流水、收入证明、子女/亲属关系材料通常是核心证据。");
        }
        return out;
    }

    private List<String> buildHandlingPath(int unprovedCount) {
        List<String> out = new ArrayList<>();
        out.add("先补齐高优先级未证成事实对应证据。");
        out.add("对关键证据做时间线整理（发生时间-证据来源-证明目的）。");
        if (unprovedCount > 0) {
            out.add("自行无法调取的材料，立案后申请调查令/调取令。");
        }
        out.add("补证后再次运行 Step2，确认证成率提升。");
        return out;
    }

    private String priorityByIndex(int idx) {
        if (idx <= 2) return "high";
        if (idx <= 4) return "medium";
        return "low";
    }

    private List<String> flattenHowTo(List<Step2EvidenceHowToItem> howTo) {
        if (howTo == null || howTo.isEmpty()) return List.of("补充可核验原始材料，并按证据-事实逐条对应。");
        LinkedHashSet<String> flat = new LinkedHashSet<>();
        for (Step2EvidenceHowToItem i : howTo) {
            if (i == null || i.getHowTo() == null) continue;
            flat.addAll(i.getHowTo());
        }
        return flat.isEmpty() ? List.of("补充可核验原始材料，并按证据-事实逐条对应。") : new ArrayList<>(flat);
    }

    private double round2(double v) {
        return Math.round(v * 100d) / 100d;
    }

    private List<Step2EvidenceHowToItem> buildEvidenceHowTo(String causeCode, List<String> evidenceTypes) {
        if (evidenceTypes == null || evidenceTypes.isEmpty()) {
            return List.of();
        }
        // 仅在婚姻家庭大类下提供“怎么证成/证据追问”，避免误导其它法律领域
        if (causeCode == null || !causeAssetDbService.isMarriageFamilyCause(causeCode)) {
            return List.of();
        }
        List<Step2EvidenceHowToItem> out = new ArrayList<>();
        for (String ev : evidenceTypes) {
            if (ev == null || ev.isBlank()) continue;
            out.add(new Step2EvidenceHowToItem(ev, howToForEvidenceType(ev)));
        }
        return out;
    }

    private List<String> howToForEvidenceType(String ev) {
        String s = ev.trim();
        String norm = s.replace("（", "(").replace("）", ")").toLowerCase();
        LinkedHashSet<String> steps = new LinkedHashSet<>();

        // 通用兜底（先加，后续可按 evidence_type 更精细化）
        steps.add("优先提供原件或可核验的原始载体（原文件/原聊天/原App流水）。");
        steps.add("无法自行获取的，可在诉讼中申请法院调查令/调取令。");

        if (containsAny(norm, "转账", "流水", "银行", "收条", "凭证", "发票", "票据", "红包", "支付宝", "微信")) {
            steps.add("微信/支付宝：在账单/交易记录中按时间筛选导出，保留交易号与对方实名信息。");
            steps.add("银行：在手机银行下载流水/回单，或持身份证到柜台申请盖章流水。");
            steps.add("收条/借条/协议：提供原件；如仅有照片，准备形成经过与保管说明。");
        }
        if (containsAny(norm, "工资", "收入", "年薪", "月薪", "个税", "社保", "公积金")) {
            steps.add("工资/收入：工资条、劳动合同、银行代发流水、单位出具的收入证明。");
            steps.add("个税：个人所得税App下载纳税记录/收入纳税明细。");
            steps.add("社保/公积金：社保/公积金App或官网打印缴费/缴存记录。");
        }
        if (containsAny(norm, "出生证明", "户口", "户籍", "亲子鉴定", "亲属关系")) {
            steps.add("亲子/亲属关系：出生医学证明、户口簿、派出所户籍证明、村居委证明。");
            steps.add("存在争议时：可申请司法鉴定中心进行亲子鉴定。");
        }
        if (containsAny(norm, "病历", "诊断", "医疗", "失能", "护理")) {
            steps.add("医疗材料：医院病案室复印病历/诊断证明，保留发票与费用清单。");
            steps.add("护理/失能：护理记录、评残/鉴定、护理机构合同与付款凭证。");
        }
        if (containsAny(norm, "聊天", "短信", "录音", "通话", "照片", "视频", "截图")) {
            steps.add("聊天/短信：保留原始对话，截图需包含对方账号、时间；重要内容可做公证。");
            steps.add("录音/视频：保留原始文件与设备信息，必要时说明录制场景与未剪辑。");
        }
        if (containsAny(norm, "合同", "不动产", "房产证", "登记", "公证", "学校", "培训")) {
            steps.add("合同/登记：购房合同、不动产权证、登记信息可在不动产登记中心查询。");
            steps.add("教育支出：学校/培训机构开具缴费凭证、发票、课程合同与出勤记录。");
        }

        // 拆分复合字符串再补充（如 “A/B/C”）
        for (String token : splitEvidenceTokens(s)) {
            String t = token.toLowerCase();
            if (containsAny(t, "其他")) {
                steps.add("其他材料：能形成完整证明链条的文件、证人证言、现场照片等均可补充。");
            }
        }

        return new ArrayList<>(steps);
    }

    private boolean containsAny(String text, String... keys) {
        if (text == null || text.isBlank() || keys == null) return false;
        for (String k : keys) {
            if (k == null || k.isBlank()) continue;
            if (text.contains(k)) return true;
        }
        return false;
    }

    private List<String> splitEvidenceTokens(String s) {
        if (s == null || s.isBlank()) return List.of();
        return Arrays.stream(s.split("[/、,，;；\\s]+"))
                .map(String::trim)
                .filter(t -> !t.isBlank())
                .collect(Collectors.toList());
    }

    private List<Step2FollowupQuestion> buildFollowupQuestionsForEvidence(
            String causeCode,
            String factKey,
            String factLabel,
            List<String> evidenceTypes
    ) {
        if (causeCode == null || !causeAssetDbService.isMarriageFamilyCause(causeCode)) {
            return List.of();
        }
        List<Step2FollowupQuestion> out = new ArrayList<>();
        int idx = 1;
        String factText = (factLabel == null || factLabel.isBlank()) ? factKey : factLabel;

        for (String ev : evidenceTypes == null ? List.<String>of() : evidenceTypes) {
            if (ev == null || ev.isBlank()) continue;
            String norm = ev.toLowerCase();

            if (containsAny(norm, "转账", "流水", "微信", "支付宝", "银行")) {
                out.add(new Step2FollowupQuestion(
                        factKey + "_ev_" + (idx++),
                        "请填写与「" + factText + "」对应的转账记录关键信息（转账时间、金额、付款人、收款人、交易号）。",
                        "text",
                        List.of(),
                        "用于证明给付事实真实发生、金额可核验、主体对应关系明确。",
                        true
                ));
                out.add(new Step2FollowupQuestion(
                        factKey + "_ev_" + (idx++),
                        "该转账记录是否能体现明确用途（如备注“抚养费/彩礼/购房款”等）？",
                        "choice",
                        List.of("能明确体现", "不能明确体现", "部分体现"),
                        "用途明确可显著提升证据证明力，降低被抗辩为一般赠与或往来款的风险。",
                        true
                ));
            }

            if (containsAny(norm, "收入", "工资", "个税", "社保", "公积金")) {
                out.add(new Step2FollowupQuestion(
                        factKey + "_ev_" + (idx++),
                        "请补充对方近12个月收入证明来源（工资条/个税记录/社保公积金基数/银行代发流水）。",
                        "text",
                        List.of(),
                        "用于证明对方支付能力或分担能力，支撑抚养费/赡养费/财产补偿比例主张。",
                        true
                ));
            }

            if (containsAny(norm, "出生证明", "户口", "亲子", "亲属关系")) {
                out.add(new Step2FollowupQuestion(
                        factKey + "_ev_" + (idx++),
                        "请说明亲属关系证明材料类型及签发机关（出生医学证明/户口簿/户籍证明/亲子鉴定）。",
                        "text",
                        List.of(),
                        "用于确认权利义务主体资格，属于婚姻家事案件的基础证明前提。",
                        true
                ));
            }

            if (containsAny(norm, "病历", "医疗", "诊断", "失能", "护理")) {
                out.add(new Step2FollowupQuestion(
                        factKey + "_ev_" + (idx++),
                        "请填写医疗/护理证据的时间区间、诊断结论及对应费用金额。",
                        "text",
                        List.of(),
                        "用于证明必要支出与持续性负担，支撑费用分担或扶养/赡养请求。",
                        true
                ));
            }

            if (containsAny(norm, "聊天", "短信", "录音", "截图", "视频")) {
                out.add(new Step2FollowupQuestion(
                        factKey + "_ev_" + (idx++),
                        "请概述电子证据中的关键表述（谁在何时作出何种承诺/确认/拒绝）。",
                        "text",
                        List.of(),
                        "用于证明主观意思表示与事实经过，形成与客观证据的相互印证链。",
                        true
                ));
            }

            if (containsAny(norm, "合同", "登记", "不动产", "房产证", "公证")) {
                out.add(new Step2FollowupQuestion(
                        factKey + "_ev_" + (idx++),
                        "请补充合同/登记材料中的核心字段（签署日期、登记权利人、份额比例、权利限制）。",
                        "text",
                        List.of(),
                        "用于确定财产权属基础与权利边界，是财产分割争议中的核心证明点。",
                        true
                ));
            }
        }

        if (out.isEmpty()) {
            out.add(new Step2FollowupQuestion(
                    factKey + "_ev_1",
                    "请详细说明你已掌握的证据：来源、形成时间、关键内容、与「" + factText + "」的对应关系。",
                    "text",
                    List.of(),
                    "用于建立“证据-事实-法律要件”的对应链条，提升该要件证成度。",
                    true
            ));
        }
        return out;
    }

    public List<Map<String, Object>> causes() {
        return causeAssetDbService.listEnabledCauses();
    }

    public List<CauseCategory> categories() {
        return causeAssetDbService.listEnabledCategoriesTree();
    }

    public CauseCategory category(String categoryCode) {
        return causeAssetDbService.getEnabledCategory(categoryCode);
    }

    public List<CauseItem> commonCauses(String categoryCode) {
        return causeAssetDbService.listCommonCauses(categoryCode);
    }

    public List<Map<String, Object>> questionnaire(String causeCode, String questionnaireId) {
        String normalized = normalizeCauseCode(causeCode);
        return causeAssetDbService.getQuestionGroups(normalized);
    }

    private String normalizeCauseCode(String causeCode) {
        if (causeCode == null || causeCode.isBlank()) {
            // 默认走当前规则库里“离婚/房产分割”链路（避免 Step2 取不到 target）
            return CAUSE_DIVORCE;
        }
        String c = causeCode.trim();
        // 兼容旧接口/旧 causeCode：divorce_property -> property_dispute
        // 前端旧的 property_dispute 统一映射为当前库里的 divorce_property
        if (CAUSE_PROPERTY_DISPUTE.equals(c)) {
            return CAUSE_DIVORCE;
        }
        return c;
    }

}
