# MySQL 首次启动自动执行（与 DaMai 相同机制）

MySQL 官方镜像会在**数据目录为空**时，按文件名顺序执行本目录下所有 `.sql` / `.sh`。

## 推荐做法（完整库）

1. 在本机用 `mysqldump` 导出完整库（见项目根目录 `DEPLOY_DOCKER.md`）。
2. 将导出文件**复制到本目录**，并命名为 **`init.sql`**（仅此一个即可）：

   ```bash
   cp /path/to/rule_engine_db_init.sql ./init.sql
   ```

3. **第一次**执行 `docker compose up -d` 前，确保 MySQL 使用**空数据卷**（否则不会再次执行 init）。

## 已有数据卷时要重建库

会删除容器内 MySQL 全部数据，请确认可接受后再执行：

```bash
docker compose down
docker volume rm rule-backend_db_data   # 名称以 docker volume ls 为准
docker compose up -d
```

## 为何不用仓库里多条 migrate_*.sql 自动跑？

部分脚本含 `ALTER TABLE`，依赖已有表结构，**不能**在完全空库上单独按顺序执行。完整业务数据请以 **一份 mysqldump** 或你维护好的 **单文件 init.sql** 为准。

## 不要提交到 Git

`init.sql` 通常很大且含环境数据，已加入 `.gitignore`，仅在服务器或本机部署目录放置即可。
