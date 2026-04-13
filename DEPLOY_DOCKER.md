# Docker Deployment Guide

Server IP: `8.136.46.14`

## 1) Upload project

Upload the whole `rule-backend` directory to server, for example:

- `/opt/rule-backend`

## 2) Prepare environment file

Create `.env` under `/opt/rule-backend`:

```env
MYSQL_ROOT_PASSWORD=change_me_strong_password
# AI 问卷预填（DeepSeek）；不配则仅关键词降级，不配也可启动
RULE_AI_DEEPSEEK_KEY=your_deepseek_api_key
```

可参考仓库内 `.env.example`。

## 3) 数据库自动初始化（推荐，与 DaMai 相同）

1. 在本机用 `mysqldump` 导出完整库，例如：

   ```bash
   mysqldump -h127.0.0.1 -uroot -p --databases rule_engine_db --result-file=rule_engine_db_init.sql
   ```

2. 在服务器上放到：

   `sql/docker-entrypoint-initdb.d/init.sql`

   例如：

   ```bash
   mv /opt/rule-backend/rule_engine_db_init.sql /opt/rule-backend/sql/docker-entrypoint-initdb.d/init.sql
   ```

3. **仅当 MySQL 数据卷为空时**会自动执行；若之前起过库，需删卷重建：

   ```bash
   docker compose down
   docker volume rm rule-backend_db_data
   ```

   卷名以 `docker volume ls | grep rule` 为准。

详见：`sql/docker-entrypoint-initdb.d/README.md`。

## 4) Start services

`docker-compose` 已设置 `SPRING_PROFILES_ACTIVE=docker`，会加载 `application-docker.yml`，使用 `db`、`redis` 服务名。**构建阶段使用官方镜像 `maven:3.9-eclipse-temurin-21-alpine`**，避免在 Alpine 里 `apk add maven` 因网络/TLS 失败。

```bash
cd /opt/rule-backend
docker compose build --no-cache rule-backend
docker compose up -d
```

### git pull 若提示 `rule_engine_db_init.sql` 会覆盖合并

该文件应放在 `sql/docker-entrypoint-initdb.d/init.sql`，或移到家目录后再 pull：

```bash
mv rule_engine_db_init.sql ~/rule_engine_db_init.sql.bak
git pull origin main
```

## 5) Initialize database（可选：未用 init.sql 时手动执行迁移）

### 5.0 空库或报错 `Table 'rule_engine_db.rule_law' doesn't exist`

法条增强脚本（`migrate_refine_eight_causes_*.sql`）以及 **5.2** 里多数迁移都假定 **`rule_law` 等核心表与基础数据已存在**。若 Docker 里只有用户表、或从未灌过规则数据，应**先**导入仓库根下的完整 dump：

- 文件：`rule_engine_db_full.sql`（与 `DEPLOY_DOCKER.md` 同目录，即 `rule-backend/rule_engine_db_full.sql`）

该文件会 **`DROP TABLE IF EXISTS` 并重建** dump 内出现的表，相当于**重置规则库相关表及数据**；若你曾在同一库手工加过微信字段，以 dump 中的 `rule_user_profile` 结构为准，导入后需再跑 **`migrate_wechat_auth.sql`** 补齐 `wx_*` 列与索引。

#### 5.0.1 Windows + PowerShell：从零到「规则库 + 法条增强 + 微信字段」完整步骤

下面按**推荐顺序**写全；所有路径以在 **`rule-backend` 根目录**打开 PowerShell 为前提（请把示例盘符改成你的实际路径）。

**（一）前提**

1. 已安装 Docker Desktop，且 **`rule-db` 容器在运行**（`docker compose` 里的服务名是 `db`，容器名是 `rule-db`）。
2. 知道 **MySQL root 密码**：与 `docker-compose.yml` 一致，默认未改时为 **`1234`**；若你在仓库根目录 `.env` 里设置了 `MYSQL_ROOT_PASSWORD`，以该值为准。
3. 本机连接容器内 MySQL 时，宿主机端口一般为 **`3307`**（映射 `3307:3306`），用户名 **`root`**，数据库名 **`rule_engine_db`**。

**（二）确认数据库与容器可用**

```powershell
docker ps --filter "name=rule-db"
docker exec rule-db sh -c "mysql -uroot -p1234 -e \"SHOW DATABASES LIKE 'rule_engine_db';\""
```

将上面命令里的 `1234` 换成你的 root 密码。若容器不存在或未运行，先在 `rule-backend` 目录执行：`docker compose up -d db`（或 `docker compose up -d` 起全套）。

**（三）导入完整库 `rule_engine_db_full.sql`（必须先做，否则没有 `rule_law`）**

说明：该文件体积较大，内含 `CREATE DATABASE` / `USE`、多表 `DROP` + `CREATE` + 数据；执行一次等于把 dump 里的表结构及数据**覆盖成快照状态**。**仅用户会话等若不在 dump 里会被一起按 dump 处理**（见下文微信步骤）。

在 PowerShell 中（**不要用管道从本机直接喂中文 SQL**，用 `docker cp` 最稳）：

```powershell
cd D:\code\tiaozhanzhebei\rule-backend

docker cp .\rule_engine_db_full.sql rule-db:/tmp/
docker exec rule-db sh -c "mysql -uroot -p1234 --default-character-set=utf8mb4 rule_engine_db < /tmp/rule_engine_db_full.sql"
```

- 将 **`1234`** 换成你的 **`MYSQL_ROOT_PASSWORD`**。
- 成功时一般只有 `mysql: [Warning] Using a password on the command line...`，无 `ERROR`。

**（四）可选：仅当 `rule_user_profile` 仍不存在时**

若完整导入因故未包含用户表、或你用的是极早的 dump，可先执行用户层建表脚本（与 **5.3** 表一致）：

```powershell
docker cp .\sql\migrate_user_data_layer.sql rule-db:/tmp/
docker exec rule-db sh -c "mysql -uroot -p1234 --default-character-set=utf8mb4 rule_engine_db < /tmp/migrate_user_data_layer.sql"
```

完整 `rule_engine_db_full.sql` 通常已含 `rule_user_profile`，此步多数环境**可跳过**。

**（五）微信小程序相关字段（`migrate_wechat_auth.sql`）**

仓库里的完整 dump 中 **`rule_user_profile` 往往没有 `wx_app_id` / `wx_openid` / `wx_unionid`**，需要执行：

```powershell
docker cp .\sql\migrate_wechat_auth.sql rule-db:/tmp/
docker exec rule-db sh -c "mysql -uroot -p1234 --default-character-set=utf8mb4 rule_engine_db < /tmp/migrate_wechat_auth.sql"
```

- **若列与唯一索引已存在**，可能报 duplicate column / duplicate key，属正常，说明已跑过，可忽略或改用手工 `ALTER` 检查。
- 不需要微信登录时，本步可跳过。

**（六）法条与八类案由增强（两条脚本，顺序固定）**

```powershell
docker cp .\sql\migrate_refine_eight_causes_official_law_text.sql rule-db:/tmp/
docker cp .\sql\migrate_refine_eight_causes_phase2.sql rule-db:/tmp/
docker exec rule-db sh -c "mysql -uroot -p1234 --default-character-set=utf8mb4 rule_engine_db < /tmp/migrate_refine_eight_causes_official_law_text.sql"
docker exec rule-db sh -c "mysql -uroot -p1234 --default-character-set=utf8mb4 rule_engine_db < /tmp/migrate_refine_eight_causes_phase2.sql"
```

**（七）后端环境变量（使用微信登录时）**

在 **`rule-backend/.env`**（可由 `.env.example` 复制）中至少配置：

| 变量 | 含义 |
|------|------|
| `MYSQL_ROOT_PASSWORD` | 与 Docker `db` 一致 |
| `WECHAT_MINIAPP_APP_ID` | 小程序 AppID |
| `WECHAT_MINIAPP_SECRET` | 小程序 AppSecret（仅服务端） |
| `RULE_AUTH_JWT_SECRET` | JWT 签名密钥，建议 ≥32 字符随机串 |

保存后重启后端容器使环境变量生效：

```powershell
docker compose up -d --build rule-backend
```

（若仅改 `.env` 且镜像未变，可用 `docker compose up -d rule-backend`。）

**（八）简单验证**

```powershell
docker exec rule-db sh -c "mysql -uroot -p1234 --default-character-set=utf8mb4 -e \"USE rule_engine_db; SHOW TABLES LIKE 'rule_law'; DESCRIBE rule_user_profile;\""
```

应能看到 **`rule_law` 表存在**，且 **`rule_user_profile` 含 `wx_*` 列**（若已执行 **（五）**）。接口探测示例：`curl http://127.0.0.1:8080/api/rule/causes`（需 **`rule-backend` 已启动**）。

**（九）与「先只建用户表再灌 full」的关系**

若你曾先执行过 `migrate_user_data_layer.sql` / `migrate_wechat_auth.sql` 再导入 **`rule_engine_db_full.sql`**：**完整 dump 会按 dump 内容重建表**，你在 dump 之外的本地改动可能被覆盖；导入后请**重新执行（五）** 微信迁移（若需要）。

**（十）一键命令汇总（复制后按需改密码与路径）**

```powershell
cd D:\code\tiaozhanzhebei\rule-backend
$pw = "1234"

docker cp .\rule_engine_db_full.sql rule-db:/tmp/
docker exec rule-db sh -c "mysql -uroot -p$pw --default-character-set=utf8mb4 rule_engine_db < /tmp/rule_engine_db_full.sql"

docker cp .\sql\migrate_wechat_auth.sql rule-db:/tmp/
docker exec rule-db sh -c "mysql -uroot -p$pw --default-character-set=utf8mb4 rule_engine_db < /tmp/migrate_wechat_auth.sql"

docker cp .\sql\migrate_refine_eight_causes_official_law_text.sql rule-db:/tmp/
docker cp .\sql\migrate_refine_eight_causes_phase2.sql rule-db:/tmp/
docker exec rule-db sh -c "mysql -uroot -p$pw --default-character-set=utf8mb4 rule_engine_db < /tmp/migrate_refine_eight_causes_official_law_text.sql"
docker exec rule-db sh -c "mysql -uroot -p$pw --default-character-set=utf8mb4 rule_engine_db < /tmp/migrate_refine_eight_causes_phase2.sql"
```

**Windows PowerShell（仅灌库、与 5.1 相同：`docker cp` + 容器内重定向）** 单步示例：

```powershell
cd D:\code\tiaozhanzhebei\rule-backend   # 按实际路径
docker cp .\rule_engine_db_full.sql rule-db:/tmp/
docker exec rule-db sh -c "mysql -uroot -p1234 --default-character-set=utf8mb4 rule_engine_db < /tmp/rule_engine_db_full.sql"
```

（将 `1234` 换成你的 `MYSQL_ROOT_PASSWORD`。）

### 5.1 已有数据库：仅做法条与八类案由增强（增量，推荐）

库已存在且曾导入过 `rule_engine_db_full.sql` 或历史 dump 时，一般**先**按序执行下面两条法条增强脚本（可重复执行，幂等）：

若前端需要“纠纷大类 → 小类案由”树形结构（首页大类卡片），请先执行一次：

```bash
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_cause_categories.sql
```

```bash
cd /opt/rule-backend   # 或本机 rule-backend 根目录

docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_refine_eight_causes_official_law_text.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_refine_eight_causes_phase2.sql
```

若使用 **微信小程序登录**，再执行一次（**仅首次**，重复执行可能因唯一索引已存在而报错）：

```bash
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_wechat_auth.sql
```

并在 `.env` 中配置 `WECHAT_MINIAPP_APP_ID`、`WECHAT_MINIAPP_SECRET`、`RULE_AUTH_JWT_SECRET`，`docker compose up` 传入后端容器（见仓库 `docker-compose.yml`）。

本机未用 Docker 时，将 `docker exec -i rule-db mysql ...` 换成：

`mysql -h127.0.0.1 -uroot -p rule_engine_db < sql/...`（路径相对于 `rule-backend`）。

**Windows PowerShell**：不要用 `Get-Content ... | docker exec` 默认编码执行含中文的 SQL，易出现 `????` 与 `ERROR 1064`。任选其一：

- **推荐**：把文件拷进容器再执行（UTF-8 原样保留）：

```powershell
cd D:\code\tiaozhanzhebei\rule-backend # 按实际路径
docker cp .\sql\migrate_refine_eight_causes_official_law_text.sql rule-db:/tmp/
docker cp .\sql\migrate_refine_eight_causes_phase2.sql rule-db:/tmp/
docker exec rule-db sh -c "mysql -uroot -p1234 --default-character-set=utf8mb4 rule_engine_db < /tmp/migrate_refine_eight_causes_official_law_text.sql"
docker exec rule-db sh -c "mysql -uroot -p1234 --default-character-set=utf8mb4 rule_engine_db < /tmp/migrate_refine_eight_causes_phase2.sql"
```

（将 `1234` 换成你的 `MYSQL_ROOT_PASSWORD`。）

- 或：`Get-Content .\sql\xxx.sql -Raw -Encoding utf8 | docker exec -i rule-db mysql ... --default-character-set=utf8mb4 rule_engine_db`

**若报错 `rule_user_profile` 不存在**：说明当前 Docker 库尚未建用户表，需先执行 `sql/migrate_user_data_layer.sql`（同样建议 `docker cp` + 容器内 `mysql <`），再执行 `migrate_wechat_auth.sql`。若还缺 `rule_law` 等核心表，应对该库做一次完整初始化（`init.sql` 或 `DEPLOY_DOCKER` 5.2 迁移链），不能只跑法条脚本。

### 5.2 从零手动跑迁移链（未用 init.sql 时）

若未使用 `init.sql` 自动初始化，可按顺序手动导入（**顺序勿乱**；`migrate_labor_rules.sql` 依赖 Step2 表，需先有 `bootstrap_step2_tables.sql`）：

```bash
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_rule_judge_tables.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_cause_asset_mapping.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/bootstrap_step2_tables.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_labor_rules.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_additional_causes.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_rule_judge_data_labor.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_rule_judge_data_divorce.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_refine_eight_causes_official_law_text.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_refine_eight_causes_phase2.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_wechat_auth.sql
```

说明：`migrate_labor_rules.sql`、`migrate_additional_causes.sql` 仓库内已修正部分法条（如 `law_reg_16` 第十八条、`law_jshj_5` 全文）；**完整官样条文与法释〔2024〕1 号等**仍由上述两条 `migrate_refine_eight_causes_*.sql` 统一补齐。微信登录依赖 `migrate_wechat_auth.sql`。

### 5.3 其余脚本（按业务需要）

| 文件 | 用途 |
|------|------|
| `migrate_case_library_and_report.sql` | 案例库等 |
| `migrate_user_data_layer.sql` | 用户会话/提交表 |
| `migrate_law_official_sources.sql` | 法条来源备注表（可选） |
| `fix_rule_questionnaire_collation.sql` | 问卷库字符集/排序规则修复 |
| `seed_rule_questionnaire_registry.sql` | 问卷注册表种子 |
| `migrate_labor_rules_retry.sql` | 历史重试用，一般不必 |

使用 **`sql/docker-entrypoint-initdb.d/init.sql`** 一次性灌库时，若 dump 早于法条完善，在业务低峰对**同一库**补跑 **5.1** 两条即可。

## 6) Check service status

```bash
docker compose ps
docker compose logs -f rule-backend
```

Backend is ready when logs show Spring Boot started successfully.

## 7) Verify API

Open in browser:

- Swagger UI: `http://8.136.46.14:8080/swagger-ui/index.html`
- OpenAPI JSON: `http://8.136.46.14:8080/v3/api-docs`

Quick check:

```bash
curl "http://8.136.46.14:8080/api/rule/causes"
```

### AI 预填（异步可选）

同步接口（兼容，直接返回结果）：

- `POST /api/rule/ai-prefill`

异步接口（推荐用于调用耗时较长场景：先提交任务，再轮询结果）：

- `POST /api/rule/ai-prefill/submit` → 返回 `taskId`
- `GET /api/rule/ai-prefill/task/{taskId}` → 返回 `queued/running/success/failed`

RabbitMQ 管理台（若 compose 暴露 15672 端口）：

- `http://<server-ip>:15672`（默认用户/密码见 `.env` 的 `MQ_USER`/`MQ_PASSWORD`）

## 8) Give frontend these URLs

- Base URL: `http://8.136.46.14:8080`
- Docs URL: `http://8.136.46.14:8080/swagger-ui/index.html`
- OpenAPI URL: `http://8.136.46.14:8080/v3/api-docs`

## 9) Common operations

Restart:

```bash
docker compose restart rule-backend
```

Update after code change:

```bash
docker compose up -d --build rule-backend
```

Stop all:

```bash
docker compose down
```
