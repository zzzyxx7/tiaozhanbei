# rule-backend

规则引擎与问卷、判题、报告、AI 预填等 HTTP API。

- 部署与 **数据库 SQL 执行顺序**：见 [`DEPLOY_DOCKER.md`](DEPLOY_DOCKER.md) 第 5 节（含「已有库增量」与「从零迁移链」）。
- 前端对接：[`FRONTEND_API.md`](FRONTEND_API.md)。

法条与八类案由的增量增强脚本位于 `sql/migrate_refine_eight_causes_official_law_text.sql` 与 `sql/migrate_refine_eight_causes_phase2.sql`，**无需改 Java** 即可生效。
