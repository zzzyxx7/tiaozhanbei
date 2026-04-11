# Docker Deployment Guide

Server IP: `8.136.46.14`

## 1) Upload project

Upload the whole `rule-backend` directory to server, for example:

- `/opt/rule-backend`

## 2) Prepare environment file

Create `.env` under `/opt/rule-backend`:

```env
MYSQL_ROOT_PASSWORD=change_me_strong_password
```

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

若未使用 `init.sql` 自动初始化，可按顺序手动导入（部分脚本依赖已有表，顺序勿乱）：

```bash
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_rule_judge_tables.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_cause_asset_mapping.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_labor_rules.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_additional_causes.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_rule_judge_data_labor.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_rule_judge_data_divorce.sql
```

仓库中其余 `sql/migrate_*.sql`（如 `migrate_law_official_sources.sql`、`migrate_user_data_layer.sql` 等）按业务需要再执行。

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
