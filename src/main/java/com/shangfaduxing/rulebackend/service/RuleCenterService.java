package com.shangfaduxing.rulebackend.service;

import com.shangfaduxing.rulebackend.model.CauseCategory;
import com.shangfaduxing.rulebackend.model.JudgeResponse;
import com.shangfaduxing.rulebackend.model.Step2EvidenceChecklistItem;
import com.shangfaduxing.rulebackend.model.Step2FactChecklistItem;
import com.shangfaduxing.rulebackend.model.Step2PlanResponse;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
public class RuleCenterService {

    private static final String CAUSE_DIVORCE = "divorce_property";

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
            return resp;
        }
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
        resp.setLegalBasis(causeAssetDbService.getLawsByCause(normalized).stream()
                .filter(l -> target.legalRefs.contains(l.getId()))
                .collect(Collectors.toList()));
        resp.setFactChecklist(factChecklist);
        resp.setEvidenceChecklist(evidenceChecklist);
        return resp;
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

    public List<Map<String, Object>> questionnaire(String causeCode, String questionnaireId) {
        String normalized = normalizeCauseCode(causeCode);
        return causeAssetDbService.getQuestionGroups(normalized);
    }

    private String normalizeCauseCode(String causeCode) {
        if (causeCode == null || causeCode.isBlank()) {
            return CAUSE_DIVORCE;
        }
        return causeCode;
    }

}
