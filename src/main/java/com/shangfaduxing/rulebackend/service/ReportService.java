package com.shangfaduxing.rulebackend.service;

import com.shangfaduxing.rulebackend.model.*;
import org.springframework.stereotype.Service;

import java.util.stream.Collectors;

@Service
public class ReportService {
    private final RuleCenterService ruleCenterService;

    public ReportService(RuleCenterService ruleCenterService) {
        this.ruleCenterService = ruleCenterService;
    }

    public ReportResponse generate(String causeCode, java.util.Map<String, Object> answers, String title) {
        JudgeResponse judge = ruleCenterService.judge(causeCode, answers);
        ReportResponse resp = new ReportResponse();
        // success 表示“报告是否生成成功”，不等同于“是否命中规则”
        resp.setSuccess(true);
        resp.setMessage(judge.isSuccess() ? "报告生成完成（命中规则）" : "报告生成完成（未命中规则）");
        String reportTitle = (title == null || title.isBlank()) ? "规则推理报告" : title;

        String md = buildMarkdown(reportTitle, causeCode, judge);
        resp.setMarkdown(md);
        resp.setPlainText(md.replace("## ", "").replace("### ", ""));
        return resp;
    }

    private String buildMarkdown(String title, String causeCode, JudgeResponse judge) {
        StringBuilder sb = new StringBuilder();
        sb.append("## ").append(title).append("\n\n");
        sb.append("- 案由: ").append(causeCode).append("\n");
        sb.append("- 推理结果: ").append(judge.isSuccess() ? "命中规则" : "未命中规则").append("\n");
        sb.append("- 说明: ").append(judge.getMessage() == null ? "" : judge.getMessage()).append("\n\n");

        sb.append("### 核心结论\n");
        if (judge.getConclusions() == null || judge.getConclusions().isEmpty()) {
            sb.append("- 暂无结论\n\n");
        } else {
            for (Conclusion c : judge.getConclusions()) {
                sb.append("- [").append(c.getLevel()).append("] ").append(c.getResult()).append("：").append(c.getReason()).append("\n");
            }
            sb.append("\n");
        }

        sb.append("### 建议诉请\n");
        if (judge.getFinalResults() == null || judge.getFinalResults().isEmpty()) {
            sb.append("- 暂无诉请建议\n\n");
        } else {
            for (FinalResultItem f : judge.getFinalResults()) {
                sb.append("- ").append(f.getItem()).append("：").append(f.getResult()).append("（").append(f.getDetail()).append("）\n");
            }
            sb.append("\n");
        }

        sb.append("### 法律依据\n");
        if (judge.getLawsApplied() == null || judge.getLawsApplied().isEmpty()) {
            sb.append("- 暂无法条命中\n\n");
        } else {
            String laws = judge.getLawsApplied().stream()
                    .map(l -> "- " + l.getName() + " " + l.getArticle() + "：" + l.getSummary())
                    .collect(Collectors.joining("\n"));
            sb.append(laws).append("\n\n");
        }

        sb.append("### Step2 推荐目标\n");
        if (judge.getStep2() == null || judge.getStep2().getSuggestedTargetIds() == null || judge.getStep2().getSuggestedTargetIds().isEmpty()) {
            sb.append("- 暂无推荐目标\n");
        } else {
            for (String t : judge.getStep2().getSuggestedTargetIds()) {
                sb.append("- ").append(t).append("\n");
            }
        }
        return sb.toString();
    }
}
