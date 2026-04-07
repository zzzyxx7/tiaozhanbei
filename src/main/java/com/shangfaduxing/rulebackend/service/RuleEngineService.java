package com.shangfaduxing.rulebackend.service;

import com.shangfaduxing.rulebackend.model.*;
import com.shangfaduxing.rulebackend.rules.step2.Step2Target;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Java 版规则引擎（对齐小程序 utils/engine.js）
 * 说明：先迁移“离婚房产分割”单场景。后续可做多场景 registry。
 */
@Service
public class RuleEngineService {

    private final RuleDbDataService ruleDbDataService;

    public RuleEngineService(RuleDbDataService ruleDbDataService) {
        this.ruleDbDataService = ruleDbDataService;
    }

    public JudgeResponse judge(Map<String, Object> answers) {
        Map<String, Object> facts = extractFacts(answers);

        boolean preconditionMet =
                bool(facts, "存在合法婚姻关系") &&
                        bool(facts, "婚姻关系已经解除或正在解除") &&
                        bool(facts, "存在房产分割争议");

        if (!preconditionMet) {
            JudgeResponse resp = new JudgeResponse();
            resp.setSuccess(false);
            resp.setMessage("不满足离婚房产分割的前置条件");
            resp.setDetail(!bool(facts, "存在合法婚姻关系")
                    ? "双方不存在合法婚姻关系，不适用离婚房产分割规则。"
                    : !bool(facts, "婚姻关系已经解除或正在解除")
                    ? "婚姻关系尚未解除且未在解除过程中，暂不适用离婚房产分割规则。"
                    : "不存在房产分割争议，无需启动裁判程序。");
            resp.setAnswers(answers);
            resp.setFacts(facts);
            resp.setActivatedPaths(List.of());
            resp.setConclusions(List.of());
            resp.setFinalResults(List.of());
            resp.setLawsApplied(List.of());
            resp.setStep2(buildStep2Meta(Map.of(), Map.of()));
            return resp;
        }

        CompositeEval compositeEval = evaluateCompositeElements(facts);
        IntermediateEval intermediateEval = evaluateIntermediateResults(compositeEval.composite, facts);
        List<FinalResultItem> finalResults = generateFinalResult(intermediateEval.intermediate, compositeEval.composite, facts);

        Set<String> lawRefIds = new LinkedHashSet<>();
        for (ActivatedPath p : compositeEval.activatedPaths) {
            if (p.getLawRef() != null && !p.getLawRef().isBlank()) lawRefIds.add(p.getLawRef());
        }
        for (Conclusion c : intermediateEval.conclusions) {
            if (c.getLawRefs() != null) lawRefIds.addAll(c.getLawRefs());
        }
        List<Law> lawsApplied = ruleDbDataService.getLaws().stream()
                .filter(law -> lawRefIds.contains(law.getId()))
                .collect(Collectors.toList());

        Step2Meta step2 = buildStep2Meta(intermediateEval.intermediate, compositeEval.composite);

        JudgeResponse resp = new JudgeResponse();
        resp.setSuccess(true);
        resp.setMessage("裁判推理完成");
        resp.setAnswers(answers);
        resp.setFacts(facts);
        resp.setActivatedPaths(compositeEval.activatedPaths);
        resp.setConclusions(intermediateEval.conclusions);
        resp.setFinalResults(finalResults);
        resp.setLawsApplied(lawsApplied);
        resp.setStep2(step2);
        return resp;
    }

    // ============ Step2: buildStep2Plan ============
    public Step2PlanResponse buildStep2Plan(Map<String, Object> facts, String targetId) {
        Step2Target target = ruleDbDataService.getStep2Targets().stream()
                .filter(t -> Objects.equals(t.getTargetId(), targetId))
                .findFirst()
                .orElse(null);

        if (target == null) {
            Step2PlanResponse resp = new Step2PlanResponse();
            resp.setSuccess(false);
            resp.setMessage("未找到对应的目标结果配置");
            resp.setTargetId(targetId);
            resp.setLegalBasis(List.of());
            resp.setFactChecklist(List.of());
            resp.setEvidenceChecklist(List.of());
            return resp;
        }

        List<Law> legalBasis = ruleDbDataService.getLaws().stream()
                .filter(law -> (target.getLegalRefs() != null) && target.getLegalRefs().contains(law.getId()))
                .collect(Collectors.toList());

        List<Step2FactChecklistItem> factChecklist = (target.getRequiredFacts() == null ? List.<Step2Target.RequiredFact>of() : target.getRequiredFacts())
                .stream()
                .map(req -> {
                    boolean proved = facts != null && Boolean.TRUE.equals(facts.get(req.getKey()));
                    return new Step2FactChecklistItem(
                            req.getKey(),
                            req.getLabel() == null ? req.getKey() : req.getLabel(),
                            proved ? "proved" : "unproved"
                    );
                })
                .collect(Collectors.toList());

        Map<String, List<String>> evidenceMap = target.getEvidenceMap() == null ? Map.of() : target.getEvidenceMap();
        List<Step2EvidenceChecklistItem> evidenceChecklist = factChecklist.stream()
                .filter(f -> "unproved".equals(f.getStatus()))
                .map(f -> {
                    List<String> types = evidenceMap.get(f.getFact());
                    if (types == null || types.isEmpty()) {
                        types = List.of("其他可证明材料");
                    }
                    return new Step2EvidenceChecklistItem(f.getFact(), f.getLabel(), types, true);
                })
                .collect(Collectors.toList());

        Step2PlanResponse resp = new Step2PlanResponse();
        resp.setSuccess(true);
        resp.setMessage("证据指引生成完成");
        resp.setTargetId(target.getTargetId());
        resp.setTargetTitle(target.getTitle());
        resp.setTargetDesc(target.getDesc());
        resp.setLegalBasis(legalBasis);
        resp.setFactChecklist(factChecklist);
        resp.setEvidenceChecklist(evidenceChecklist);
        return resp;
    }

    public Step2PlanResponse buildStep2PlanFromAnswers(Map<String, Object> answers, String targetId) {
        Map<String, Object> facts = extractFacts(answers);
        return buildStep2Plan(facts, targetId);
    }

    // ============ Step1: extractFacts ============
    public Map<String, Object> extractFacts(Map<String, Object> answers) {
        Map<String, Object> facts = new LinkedHashMap<>();

        // 前置程序
        facts.put("存在合法婚姻关系", isTrue(answers.get("存在合法婚姻关系")));
        facts.put("婚姻关系已经解除或正在解除", isTrue(answers.get("婚姻关系已经解除或正在解除")));
        facts.put("存在房产分割争议", isTrue(answers.get("存在房产分割争议")));

        // 房产基础事实节点
        facts.put("房产购置时间_婚前", "婚前".equals(str(answers.get("房产购置时间"))));
        facts.put("房产购置时间_婚后", "婚后".equals(str(answers.get("房产购置时间"))));
        facts.put("出资主体_一方个人", "一方个人".equals(str(answers.get("房产出资主体"))));
        facts.put("出资主体_双方共同", "双方共同".equals(str(answers.get("房产出资主体"))));
        facts.put("出资主体_父母出资", "父母出资".equals(str(answers.get("房产出资主体"))) || "双方父母".equals(str(answers.get("房产出资主体"))));
        facts.put("出资性质_全款", "全款".equals(str(answers.get("房产出资性质"))));
        facts.put("出资性质_按揭", "按揭".equals(str(answers.get("房产出资性质"))));
        facts.put("登记_出资方个人", "出资方个人".equals(str(answers.get("产权登记主体"))));
        facts.put("登记_配偶", "配偶".equals(str(answers.get("产权登记主体"))));
        facts.put("登记_双方共同", "双方共同".equals(str(answers.get("产权登记主体"))));
        facts.put("登记_父母名下", "父母名下".equals(str(answers.get("产权登记主体"))));
        facts.put("婚后共同还贷", isTrue(answers.get("婚后共同还贷")));
        facts.put("增值_自然增值", "自然增值".equals(str(answers.get("房产增值类型"))));
        facts.put("增值_投资收益", "投资收益".equals(str(answers.get("房产增值类型"))));

        // 协议与赠与
        facts.put("签订离婚协议", isTrue(answers.get("签订离婚协议")));
        facts.put("协议约定房产分割", isTrue(answers.get("协议约定房产分割")));
        facts.put("存在房产赠与约定", isTrue(answers.get("存在房产赠与约定")));
        facts.put("赠与_未过户", "未过户".equals(str(answers.get("赠与完成过户"))));
        facts.put("赠与_已过户", "已过户".equals(str(answers.get("赠与完成过户"))));
        facts.put("赠与房产为彩礼", isTrue(answers.get("赠与房产认定为彩礼")));
        facts.put("双方已办结婚登记", isTrue(answers.get("双方已办结婚登记")));
        facts.put("登记后共同生活", isTrue(answers.get("登记后共同生活")));
        facts.put("婚前给付致生活困难", isTrue(answers.get("婚前给付导致生活困难")));
        facts.put("存在赠与撤销法定情形", isTrue(answers.get("存在赠与撤销法定情形")));

        // 父母出资
        facts.put("父母出资_婚前", "婚前".equals(str(answers.get("父母出资时间"))));
        facts.put("父母出资_婚后", "婚后".equals(str(answers.get("父母出资时间"))));
        facts.put("父母出资_全额", "全额".equals(str(answers.get("父母出资比例"))));
        facts.put("父母出资_部分", "部分".equals(str(answers.get("父母出资比例"))));
        facts.put("存在书面赠与合同", isTrue(answers.get("存在书面赠与合同")));
        facts.put("赠与合同归己方子女", isTrue(answers.get("赠与合同归己方子女")));
        facts.put("赠与合同赠与双方", isTrue(answers.get("赠与合同赠与双方")));

        // 过错与补偿
        facts.put("婚姻存续时长", intOr0(answers.get("婚姻存续时长")));
        String fault = str(answers.get("存在过错情形"));
        facts.put("存在过错情形", fault != null && !fault.isBlank() && !"无".equals(fault));
        facts.put("过错类型", (fault == null || fault.isBlank()) ? "无" : fault);
        facts.put("过错有充分证据", isTrue(answers.get("过错有充分证据")));
        facts.put("主张方为无过错方", isTrue(answers.get("主张方为无过错方")));
        facts.put("存在财产处置不当行为", isTrue(answers.get("存在财产处置不当行为")));
        facts.put("存在家务劳动超额负担", isTrue(answers.get("存在家务劳动超额负担")));
        facts.put("无过错方丧失居住权", isTrue(answers.get("无过错方丧失居住权")));

        // 特殊房产
        facts.put("婚前承租婚后购买公房", isTrue(answers.get("婚前承租婚后购买公房")));
        facts.put("父母名义房改房", isTrue(answers.get("父母名义房改房")));

        // 房屋处置
        facts.put("双方对房屋价值归属无法协议", isTrue(answers.get("双方对房屋价值归属无法协议")));
        facts.put("房屋处置意愿", Optional.ofNullable(str(answers.get("房屋处置意愿"))).orElse(""));

        return facts;
    }

    // ============ Step2: composite ============
    private CompositeEval evaluateCompositeElements(Map<String, Object> facts) {
        Map<String, Boolean> composite = new LinkedHashMap<>();
        List<ActivatedPath> activatedPaths = new ArrayList<>();

        // 婚前个人全款房产
        boolean preFull = bool(facts, "房产购置时间_婚前") &&
                bool(facts, "出资主体_一方个人") &&
                bool(facts, "出资性质_全款") &&
                bool(facts, "登记_出资方个人");
        composite.put("婚前个人全款房产", preFull);
        if (preFull) {
            activatedPaths.add(new ActivatedPath(
                    "婚前个人全款房产",
                    List.of("房产购置时间=婚前", "出资主体=一方个人", "出资性质=全款", "产权登记=出资方个人"),
                    "与",
                    "law_1063"
            ));
        }

        // 婚前首付婚后共同还贷房产
        boolean preMortgage = bool(facts, "房产购置时间_婚前") &&
                bool(facts, "出资主体_一方个人") &&
                bool(facts, "出资性质_按揭") &&
                bool(facts, "登记_出资方个人") &&
                bool(facts, "婚后共同还贷");
        composite.put("婚前首付婚后还贷", preMortgage);
        if (preMortgage) {
            activatedPaths.add(new ActivatedPath(
                    "婚前首付婚后共同还贷房产",
                    List.of("房产购置时间=婚前", "出资主体=一方个人", "出资性质=按揭", "产权登记=出资方个人", "婚后共同还贷=是"),
                    "与",
                    "law_jsyi_78"
            ));
        }

        // 婚后共同出资房产
        boolean postJoint = bool(facts, "房产购置时间_婚后") && bool(facts, "出资主体_双方共同");
        composite.put("婚后共同出资房产", postJoint);
        if (postJoint) {
            activatedPaths.add(new ActivatedPath(
                    "婚后共同出资房产",
                    List.of("房产购置时间=婚后", "出资主体=双方共同"),
                    "与",
                    "law_1062"
            ));
        }

        // 婚后个人财产购置房产
        boolean postPersonal = bool(facts, "房产购置时间_婚后") &&
                bool(facts, "出资主体_一方个人") &&
                bool(facts, "出资性质_全款") &&
                bool(facts, "登记_出资方个人");
        composite.put("婚后个人财产购房", postPersonal);
        if (postPersonal) {
            activatedPaths.add(new ActivatedPath(
                    "婚后个人财产购置房产",
                    List.of("房产购置时间=婚后", "出资主体=一方个人（婚前个人财产）", "出资性质=全款", "产权登记=出资方个人"),
                    "与",
                    "law_jsyi_26"
            ));
        }

        // 婚后登记双方名下
        boolean postRegisterBoth = bool(facts, "房产购置时间_婚后") && bool(facts, "登记_双方共同");
        composite.put("婚后登记双方", postRegisterBoth);
        if (postRegisterBoth) {
            activatedPaths.add(new ActivatedPath(
                    "婚后房屋登记双方名下",
                    List.of("房产购置时间=婚后", "产权登记=双方共同"),
                    "与",
                    "law_1062"
            ));
        }

        // 个人财产自然增值
        boolean personalNatural = (preFull || postPersonal) && bool(facts, "增值_自然增值");
        composite.put("个人财产自然增值", personalNatural);
        if (personalNatural) {
            activatedPaths.add(new ActivatedPath(
                    "婚前个人财产自然增值",
                    List.of("房产为个人财产", "增值类型=自然增值"),
                    "与",
                    "law_jsyi_26"
            ));
        }

        // 个人财产投资增值
        boolean personalInvest = (preFull || postPersonal) && bool(facts, "增值_投资收益");
        composite.put("个人财产投资增值", personalInvest);
        if (personalInvest) {
            activatedPaths.add(new ActivatedPath(
                    "婚前个人财产投资增值",
                    List.of("房产为个人财产", "增值类型=投资性收益"),
                    "与",
                    "law_jsyi_25"
            ));
        }

        // 父母婚前全额出资
        boolean parentPreFull = bool(facts, "出资主体_父母出资") &&
                bool(facts, "父母出资_婚前") &&
                bool(facts, "父母出资_全额") &&
                !bool(facts, "赠与合同赠与双方");
        composite.put("父母婚前全额出资", parentPreFull);
        if (parentPreFull) {
            activatedPaths.add(new ActivatedPath(
                    "父母婚前全额出资房产",
                    List.of("出资主体=父母", "出资时间=婚前", "出资比例=全额", "未明确赠与双方"),
                    "与",
                    "law_jsyi_29"
            ));
        }

        // 父母婚后全额出资无约定
        boolean parentPostFullNoAgree = bool(facts, "出资主体_父母出资") &&
                bool(facts, "父母出资_婚后") &&
                bool(facts, "父母出资_全额") &&
                !bool(facts, "赠与合同归己方子女");
        composite.put("父母婚后全额出资无约定", parentPostFullNoAgree);
        if (parentPostFullNoAgree) {
            activatedPaths.add(new ActivatedPath(
                    "父母婚后全额出资无约定房产",
                    List.of("出资主体=父母", "出资时间=婚后", "出资比例=全额", "未明确只归己方子女"),
                    "与",
                    "law_jser_8"
            ));
        }

        // 父母婚后部分出资
        boolean parentPostPart = bool(facts, "出资主体_父母出资") &&
                bool(facts, "父母出资_婚后") &&
                bool(facts, "父母出资_部分") &&
                !bool(facts, "赠与合同归己方子女");
        composite.put("父母婚后部分出资", parentPostPart);
        if (parentPostPart) {
            activatedPaths.add(new ActivatedPath(
                    "父母婚后部分出资无约定房产",
                    List.of("出资主体=父母", "出资时间=婚后", "出资比例=部分", "未明确只归己方子女"),
                    "与",
                    "law_jser_8"
            ));
        }

        // 父母明确赠与双方
        boolean parentGiftBoth = bool(facts, "出资主体_父母出资") && bool(facts, "赠与合同赠与双方");
        composite.put("父母明确赠与双方", parentGiftBoth);
        if (parentGiftBoth) {
            activatedPaths.add(new ActivatedPath(
                    "父母明确赠与夫妻双方",
                    List.of("出资主体=父母", "赠与合同明确赠与双方"),
                    "与",
                    "law_1062"
            ));
        }

        // 公房转化
        boolean publicHouse = bool(facts, "婚前承租婚后购买公房");
        composite.put("公房转化共同房产", publicHouse);
        if (publicHouse) {
            activatedPaths.add(new ActivatedPath(
                    "公房转化为共同房产",
                    List.of("婚前承租公房=是", "婚后共同财产购买=是"),
                    "与",
                    "law_jsyi_27"
            ));
        }

        // 房改房父母名下
        boolean reformHouse = bool(facts, "父母名义房改房");
        composite.put("房改房父母名下", reformHouse);
        if (reformHouse) {
            activatedPaths.add(new ActivatedPath(
                    "房改房登记在父母名下",
                    List.of("以父母名义参加房改=是", "登记在父母名下=是"),
                    "与",
                    "law_jsyi_79"
            ));
        }

        // 有效离婚协议含房产分割
        boolean agreement = bool(facts, "签订离婚协议") && bool(facts, "协议约定房产分割");
        composite.put("有效离婚协议分割", agreement);
        if (agreement) {
            activatedPaths.add(new ActivatedPath(
                    "合法有效离婚房产分割协议",
                    List.of("签订合法有效离婚协议=是", "协议明确约定房产分割方案=是"),
                    "与",
                    "law_1076"
            ));
        }

        // 可撤销未过户赠与
        boolean revocableNotTransfer = bool(facts, "存在房产赠与约定") &&
                bool(facts, "赠与_未过户") &&
                !bool(facts, "存在赠与撤销法定情形");
        composite.put("可撤销未过户赠与", revocableNotTransfer);
        if (revocableNotTransfer) {
            activatedPaths.add(new ActivatedPath(
                    "可撤销未过户房产赠与",
                    List.of("存在赠与约定=是", "未完成过户=是"),
                    "与",
                    "law_jsyi_32"
            ));
        }

        // 可撤销已过户短婚赠与
        int duration = intOr0(facts.get("婚姻存续时长"));
        boolean revocableShort = bool(facts, "存在房产赠与约定") &&
                bool(facts, "赠与_已过户") &&
                duration < 24 && duration > 0;
        composite.put("可撤销已过户短婚赠与", revocableShort);
        if (revocableShort) {
            activatedPaths.add(new ActivatedPath(
                    "可撤销已过户短婚房产赠与",
                    List.of("存在赠与约定=是", "已完成过户=是", "婚姻存续<24个月"),
                    "与",
                    "law_jser_5"
            ));
        }

        // 符合赠与法定撤销情形
        boolean revocableLegal = bool(facts, "存在房产赠与约定") &&
                bool(facts, "存在赠与撤销法定情形");
        composite.put("符合赠与法定撤销", revocableLegal);
        if (revocableLegal) {
            activatedPaths.add(new ActivatedPath(
                    "符合赠与法定撤销情形",
                    List.of("存在赠与约定=是", "存在法定撤销情形=是"),
                    "与",
                    "law_jser_5"
            ));
        }

        // 符合彩礼返还条件
        boolean bridePrice = bool(facts, "赠与房产为彩礼") &&
                (!bool(facts, "双方已办结婚登记") ||
                        (bool(facts, "双方已办结婚登记") && !bool(facts, "登记后共同生活")) ||
                        bool(facts, "婚前给付致生活困难"));
        composite.put("符合彩礼返还", bridePrice);
        if (bridePrice) {
            activatedPaths.add(new ActivatedPath(
                    "符合彩礼返还法定情形",
                    List.of("赠与房产为彩礼=是", "满足返还条件之一"),
                    "与+或",
                    "law_jsyi_5"
            ));
        }

        // 无过错方权益保护
        boolean noFault = bool(facts, "存在过错情形") &&
                bool(facts, "过错有充分证据") &&
                bool(facts, "主张方为无过错方");
        composite.put("无过错方权益保护", noFault);
        if (noFault) {
            activatedPaths.add(new ActivatedPath(
                    "无过错方权益保护情形",
                    List.of("存在过错情形=是", "有充分证据=是", "主张方为无过错方=是"),
                    "与",
                    "law_1091"
            ));
        }

        // 过错方少分不分
        boolean badDispose = bool(facts, "存在财产处置不当行为");
        composite.put("财产处置方少分不分", badDispose);
        if (badDispose) {
            activatedPaths.add(new ActivatedPath(
                    "财产处置不当方少分或不分",
                    List.of("存在隐藏/转移/变卖/毁损/挥霍行为=是"),
                    "单一条件",
                    "law_1092"
            ));
        }

        // 家务劳动补偿
        boolean housework = bool(facts, "存在家务劳动超额负担");
        composite.put("家务劳动补偿", housework);
        if (housework) {
            activatedPaths.add(new ActivatedPath(
                    "家务劳动补偿适用情形",
                    List.of("存在家务劳动超额负担=是"),
                    "单一条件",
                    "law_1088"
            ));
        }

        return new CompositeEval(composite, activatedPaths);
    }

    // ============ Step3: intermediate ============
    private IntermediateEval evaluateIntermediateResults(Map<String, Boolean> composite, Map<String, Object> facts) {
        Map<String, Boolean> intermediate = new LinkedHashMap<>();
        List<Conclusion> conclusions = new ArrayList<>();

        boolean isPersonal = or(
                composite.get("婚前个人全款房产"),
                composite.get("父母婚前全额出资"),
                composite.get("婚后个人财产购房"),
                composite.get("个人财产自然增值")
        );
        intermediate.put("房产为个人财产", isPersonal);
        if (isPersonal) {
            String reason = "";
            if (isTrue(composite.get("婚前个人全款房产"))) reason = "婚前个人全款购房，登记在出资方名下";
            else if (isTrue(composite.get("父母婚前全额出资"))) reason = "父母婚前全额出资，未明确赠与双方";
            else if (isTrue(composite.get("婚后个人财产购房"))) reason = "婚后以一方婚前个人财产全款购房";
            else if (isTrue(composite.get("个人财产自然增值"))) reason = "一方个人财产的自然增值部分";
            conclusions.add(new Conclusion(
                    "property_nature",
                    "该房产认定为夫妻一方的个人财产",
                    reason,
                    List.of("law_1063", "law_jsyi_26"),
                    "important"
            ));
        }

        boolean isCommon = or(
                composite.get("婚后共同出资房产"),
                composite.get("婚后登记双方"),
                composite.get("公房转化共同房产"),
                composite.get("父母婚后部分出资"),
                composite.get("父母婚后全额出资无约定"),
                composite.get("父母明确赠与双方"),
                composite.get("个人财产投资增值")
        );
        intermediate.put("房产为共同财产", isCommon);
        if (isCommon) {
            String reason = "";
            if (isTrue(composite.get("婚后共同出资房产"))) reason = "婚后双方共同出资购房";
            else if (isTrue(composite.get("婚后登记双方"))) reason = "婚后购房登记在双方名下";
            else if (isTrue(composite.get("公房转化共同房产"))) reason = "婚前承租公房婚后以共同财产购买";
            else if (isTrue(composite.get("父母婚后部分出资"))) reason = "父母婚后部分出资，其余夫妻共同支付";
            else if (isTrue(composite.get("父母婚后全额出资无约定"))) reason = "父母婚后全额出资，未明确只归己方子女";
            else if (isTrue(composite.get("父母明确赠与双方"))) reason = "父母明确表示赠与夫妻双方";
            else if (isTrue(composite.get("个人财产投资增值"))) reason = "一方个人财产的投资性收益部分";
            conclusions.add(new Conclusion(
                    "property_nature",
                    "该房产认定为夫妻共同财产",
                    reason,
                    List.of("law_1062", "law_jsyi_25", "law_jsyi_27", "law_jser_8"),
                    "important"
            ));
        }

        boolean isMixed = isTrue(composite.get("婚前首付婚后还贷"));
        intermediate.put("房产为混合财产", isMixed);
        if (isMixed) {
            conclusions.add(new Conclusion(
                    "property_nature",
                    "该房产认定为混合财产（个人财产+共同财产）",
                    "婚前一方首付+按揭，婚后以夫妻共同财产还贷，登记在首付方名下",
                    List.of("law_jsyi_78"),
                    "important"
            ));
        }

        boolean notSplit = isTrue(composite.get("房改房父母名下")) || isTrue(composite.get("符合彩礼返还"));
        intermediate.put("不纳入分割", notSplit);
        if (notSplit) {
            String reason = isTrue(composite.get("房改房父母名下"))
                    ? "以一方父母名义参加房改购买并登记在父母名下，不属于夫妻共同财产"
                    : "该房产被认定为彩礼性质，符合法定返还情形";
            List<String> refs = isTrue(composite.get("房改房父母名下")) ? List.of("law_jsyi_79") : List.of("law_jsyi_5");
            conclusions.add(new Conclusion(
                    "property_nature",
                    "该房产不纳入夫妻共同财产分割",
                    reason,
                    refs,
                    "critical"
            ));
        }

        // 分割规则适用：协议优先
        if (isTrue(composite.get("有效离婚协议分割"))) {
            intermediate.put("适用协议分割", true);
            conclusions.add(new Conclusion(
                    "split_rule",
                    "适用协议优先分割规则",
                    "双方已签订合法有效的离婚协议且明确约定了房产分割方案",
                    List.of("law_1076"),
                    "important"
            ));
        }

        // 赠与撤销
        if (isTrue(composite.get("可撤销未过户赠与")) ||
                isTrue(composite.get("可撤销已过户短婚赠与")) ||
                isTrue(composite.get("符合赠与法定撤销"))) {
            intermediate.put("适用赠与撤销", true);
            String reason = isTrue(composite.get("可撤销未过户赠与"))
                    ? "房产赠与尚未办理变更登记，赠与方有权撤销"
                    : isTrue(composite.get("可撤销已过户短婚赠与"))
                    ? "虽已过户但婚姻存续不足24个月，法院可综合考虑是否准许撤销"
                    : "存在法定赠与撤销情形";
            conclusions.add(new Conclusion(
                    "split_rule",
                    "适用赠与撤销规则",
                    reason,
                    List.of("law_jsyi_32", "law_jser_5"),
                    "important"
            ));
        }

        // 彩礼返还
        if (isTrue(composite.get("符合彩礼返还"))) {
            intermediate.put("适用彩礼返还", true);
            conclusions.add(new Conclusion(
                    "split_rule",
                    "适用彩礼返还规则",
                    "房产被认定为彩礼性质且符合法定返还条件",
                    List.of("law_jsyi_5"),
                    "important"
            ));
        }

        // 无过错方照顾
        if (isTrue(composite.get("无过错方权益保护"))) {
            intermediate.put("适用无过错方照顾", true);
            conclusions.add(new Conclusion(
                    "split_adjustment",
                    "适用无过错方权益照顾原则",
                    "存在" + str(facts.get("过错类型")) + "过错情形，有充分证据证明，主张方为无过错方",
                    List.of("law_1087", "law_1091"),
                    "warning"
            ));
        }

        // 过错方少分不分
        if (isTrue(composite.get("财产处置方少分不分"))) {
            intermediate.put("适用过错方少分不分", true);
            conclusions.add(new Conclusion(
                    "split_adjustment",
                    "过错方可被判决少分或不分房产份额",
                    "存在隐藏、转移、变卖、毁损、挥霍夫妻共同财产或伪造债务行为",
                    List.of("law_1092"),
                    "critical"
            ));
        }

        // 家务劳动补偿
        if (isTrue(composite.get("家务劳动补偿"))) {
            intermediate.put("适用家务劳动补偿", true);
            conclusions.add(new Conclusion(
                    "split_adjustment",
                    "适用家务劳动额外补偿规则",
                    "一方因抚育子女、照料老人、协助另一方工作负担较多义务",
                    List.of("law_1088", "law_jser_21"),
                    "info"
            ));
        }

        return new IntermediateEval(intermediate, conclusions);
    }

    // ============ Step4: final results ============
    private List<FinalResultItem> generateFinalResult(Map<String, Boolean> intermediate,
                                                     Map<String, Boolean> composite,
                                                     Map<String, Object> facts) {
        List<FinalResultItem> finalResults = new ArrayList<>();

        if (isTrue(intermediate.get("房产为个人财产"))) {
            finalResults.add(new FinalResultItem(
                    "房产最终产权归属",
                    "归产权登记方个人所有",
                    "该房产为一方个人财产，离婚时不参与分割，仍归产权登记方所有。"
            ));
            finalResults.add(new FinalResultItem(
                    "房产是否纳入离婚财产分割",
                    "否",
                    "个人财产不纳入夫妻共同财产分割范围。"
            ));
        } else if (isTrue(intermediate.get("房产为共同财产"))) {
            finalResults.add(new FinalResultItem(
                    "房产最终产权归属",
                    "归夫妻双方共同共有",
                    "该房产为夫妻共同财产，离婚时应当依法分割。"
            ));
            finalResults.add(new FinalResultItem(
                    "房产是否纳入离婚财产分割",
                    "是",
                    "共同财产应当纳入离婚财产分割范围。"
            ));
        } else if (isTrue(intermediate.get("房产为混合财产"))) {
            finalResults.add(new FinalResultItem(
                    "房产最终产权归属",
                    "房产归登记方，共同还贷部分需补偿",
                    "房产归不动产登记一方所有，尚未归还的贷款为登记方的个人债务。双方婚后共同还贷支付的款项及其相对应财产增值部分，由不动产登记一方对另一方进行补偿。"
            ));
            finalResults.add(new FinalResultItem(
                    "房产是否纳入离婚财产分割",
                    "部分纳入（共同还贷及增值部分）",
                    "房产本体不分割，但共同还贷金额及对应增值部分需要补偿。"
            ));
        } else if (isTrue(intermediate.get("不纳入分割"))) {
            String result = isTrue(composite.get("房改房父母名下")) ? "归出资方父母所有" : "应返还给付方";
            String detail = isTrue(composite.get("房改房父母名下"))
                    ? "该房产登记在父母名下，不属于夫妻共同财产，购房出资可作为债权处理。"
                    : "该房产被认定为彩礼，符合法定返还条件，应返还给付方。";
            finalResults.add(new FinalResultItem("房产最终产权归属", result, detail));
            finalResults.add(new FinalResultItem("房产是否纳入离婚财产分割", "否", "不纳入夫妻共同财产分割。"));
        }

        // 共同房产分割方式
        if (isTrue(intermediate.get("房产为共同财产")) && bool(facts, "双方对房屋价值归属无法协议")) {
            String wish = str(facts.get("房屋处置意愿"));
            String method;
            if ("竞价".equals(wish)) method = "竞价取得";
            else if ("评估补偿".equals(wish)) method = "评估机构评估后，取得方给予另一方补偿";
            else if ("拍卖变卖".equals(wish)) method = "拍卖或变卖后分割价款";
            else method = "由法院根据具体情况裁定处置方式";
            finalResults.add(new FinalResultItem(
                    "共同房产最终分割方式",
                    method,
                    "双方对房屋价值及归属无法达成协议时，法院依法采取上述方式处理。"
            ));
        }

        // 协议优先
        if (isTrue(intermediate.get("适用协议分割"))) {
            finalResults.add(new FinalResultItem(
                    "协议分割",
                    "按照离婚协议约定执行",
                    "双方已有合法有效的离婚协议约定房产分割方案，应当优先按协议执行。"
            ));
        }

        // 赠与撤销
        if (isTrue(intermediate.get("适用赠与撤销"))) {
            String detail = isTrue(composite.get("可撤销未过户赠与"))
                    ? "赠与未完成不动产变更登记，赠与方有权依法撤销。"
                    : "法院将综合考虑婚姻存续时间、过错等因素判断是否准许撤销。";
            finalResults.add(new FinalResultItem(
                    "房产赠与行为是否被判决撤销",
                    "可能被撤销",
                    detail
            ));
        }

        // 补偿与调整
        if (isTrue(intermediate.get("房产为混合财产"))) {
            finalResults.add(new FinalResultItem(
                    "共同还贷及增值补偿",
                    "登记方应补偿另一方",
                    "补偿金额 = 共同还贷本息总额 + 共同还贷对应的房产增值部分。具体计算公式：补偿额 = 共同还贷总额 ×（离婚时房产市值 ÷ 购房时房产总价）÷ 2。"
            ));
        }
        if (isTrue(intermediate.get("适用家务劳动补偿"))) {
            finalResults.add(new FinalResultItem(
                    "家务劳动额外补偿",
                    "负担较多义务方有权获得补偿",
                    "补偿数额由法院综合考虑家务劳动内容和时间、双方经济状况、当地一般生活水平等因素确定。"
            ));
        }
        if (isTrue(intermediate.get("适用过错方少分不分"))) {
            finalResults.add(new FinalResultItem(
                    "过错方分割比例调整",
                    "过错方可被少分或不分",
                    "因存在隐藏、转移、变卖、毁损、挥霍财产或伪造债务行为，法院可判决过错方少分或不分房产份额。"
            ));
        }
        if (isTrue(intermediate.get("适用无过错方照顾"))) {
            finalResults.add(new FinalResultItem(
                    "无过错方优先照顾",
                    "无过错方获得房产分割优先照顾",
                    "法院在分割共同财产时，照顾子女、女方和无过错方的权益。无过错方还可以另行主张离婚损害赔偿。"
            ));
        }

        return finalResults;
    }

    // ============ Step2 meta (targets + suggested ids) ============
    private Step2Meta buildStep2Meta(Map<String, Boolean> intermediate, Map<String, Boolean> composite) {
        List<Step2Target> allTargets = ruleDbDataService.getStep2Targets();
        List<Step2TargetMeta> targets = allTargets.stream()
                .map(t -> new Step2TargetMeta(t.getTargetId(), t.getTitle(), t.getDesc()))
                .collect(Collectors.toList());

        List<String> suggested = new ArrayList<>();
        if (isTrue(intermediate.get("适用无过错方照顾"))) {
            suggested.add("target_no_fault_more_share");
        }
        if (isTrue(intermediate.get("房产为共同财产"))) {
            suggested.add("target_common_property_split");
        }
        if (suggested.isEmpty()) {
            suggested = allTargets.stream().map(Step2Target::getTargetId).collect(Collectors.toList());
        } else {
            Set<String> existing = allTargets.stream().map(Step2Target::getTargetId).collect(Collectors.toSet());
            suggested = suggested.stream().filter(existing::contains).distinct().collect(Collectors.toList());
            if (suggested.isEmpty()) {
                suggested = allTargets.stream().map(Step2Target::getTargetId).collect(Collectors.toList());
            }
        }
        return new Step2Meta(targets, suggested);
    }

    // ============ helpers ============
    private static boolean isTrue(Boolean b) {
        return b != null && b;
    }

    private static boolean or(Boolean... values) {
        for (Boolean v : values) {
            if (v != null && v) return true;
        }
        return false;
    }

    private static boolean bool(Map<String, Object> facts, String key) {
        Object v = facts.get(key);
        if (v instanceof Boolean) return (Boolean) v;
        return v != null && "true".equalsIgnoreCase(String.valueOf(v));
    }

    private static String str(Object v) {
        if (v == null) return null;
        return String.valueOf(v);
    }

    private static boolean isTrue(Object v) {
        if (v instanceof Boolean) return (Boolean) v;
        if (v instanceof String) return "true".equalsIgnoreCase((String) v);
        if (v instanceof Number) return ((Number) v).intValue() != 0;
        return false;
    }

    private static int intOr0(Object v) {
        if (v == null) return 0;
        if (v instanceof Number) return ((Number) v).intValue();
        try {
            return Integer.parseInt(String.valueOf(v));
        } catch (Exception ignored) {
            return 0;
        }
    }

    private record CompositeEval(Map<String, Boolean> composite, List<ActivatedPath> activatedPaths) {}

    private record IntermediateEval(Map<String, Boolean> intermediate, List<Conclusion> conclusions) {}
}

