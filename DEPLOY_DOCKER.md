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

## 3) Start services

`docker-compose` 已设置 `SPRING_PROFILES_ACTIVE=docker`，会加载 `application-docker.yml`，使用 `db`、`redis` 服务名连接数据库与缓存。**不要用默认的 `dev` 配置**（其中 `127.0.0.1` 在容器内指向本容器，会导致连不上 MySQL/Redis、进程反复重启）。

`Dockerfile` 里必须使用 **`target/rule-backend-0.0.1-SNAPSHOT.jar`**（Spring Boot 可执行 fat jar），不能使用 `cp target/*.jar`，否则会误拷 `*-plain.jar`，容器日志会出现 `no main manifest attribute`。

```bash
cd /opt/rule-backend
docker compose build --no-cache rule-backend
docker compose up -d
```

## 4) Initialize database (run once)

Execute SQL in this order:

```bash
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_rule_judge_tables.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_cause_asset_mapping.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_labor_rules.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_additional_causes.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_rule_judge_data_labor.sql
docker exec -i rule-db mysql -uroot -p"$MYSQL_ROOT_PASSWORD" rule_engine_db < sql/migrate_rule_judge_data_divorce.sql
```

## 4) Check service status

```bash
docker compose ps
docker compose logs -f rule-backend
```

Backend is ready when logs show Spring Boot started successfully.

## 5) Verify API

Open in browser:

- Swagger UI: `http://8.136.46.14:8080/swagger-ui/index.html`
- OpenAPI JSON: `http://8.136.46.14:8080/v3/api-docs`

Quick check:

```bash
curl "http://8.136.46.14:8080/api/rule/causes"
```

## 6) Give frontend these URLs

- Base URL: `http://8.136.46.14:8080`
- Docs URL: `http://8.136.46.14:8080/swagger-ui/index.html`
- OpenAPI URL: `http://8.136.46.14:8080/v3/api-docs`

## 7) Common operations

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

