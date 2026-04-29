# 网站首页与域名接入说明

这个项目现在已经补上了一个可公开访问的首页：

- Spring Boot 首页：`/`
- Swagger 文档：`/swagger-ui/index.html`
- OpenAPI：`/v3/api-docs`

并且已经把 `nginx` 加进 `docker compose`，你不需要再单独在宿主机安装配置 Nginx。

## 你的目标结果

下面两个地址都能直接打开首页，不再需要 `:8080`：

- `http://zzzyxx.cn`
- `http://www.zzzyxx.cn`

## 上线步骤

### 1. 服务器上更新代码

```bash
cd /opt/rule-backend
git pull origin main
```

如果你的分支不是 `main`，把它换成实际分支名。

### 2. 启动或重建容器

```bash
cd /opt/rule-backend
docker compose up -d --build
```

这一步会启动：

- `rule-backend`
- `nginx`
- `db`
- `redis`
- `mq`

### 3. 开放阿里云安全组端口

至少确认下面端口已放行：

- `80/tcp`
- `8080/tcp`（可保留，仅用于你自己调试）

如果你之后要上 HTTPS，再开放：

- `443/tcp`

### 4. 检查域名解析

确认这两个记录都指向 `8.136.46.14`：

- `@` -> `8.136.46.14`
- `www` -> `8.136.46.14`

### 5. 检查容器状态

```bash
docker compose ps
docker compose logs --tail=100 nginx
docker compose logs --tail=100 rule-backend
```

## 验证命令

先在服务器本机检查：

```bash
curl http://127.0.0.1:8080/
curl http://127.0.0.1/
curl http://127.0.0.1/v3/api-docs
```

再在你本地电脑或手机流量下访问：

```text
http://zzzyxx.cn
http://www.zzzyxx.cn
http://8.136.46.14
```

## 如果 80 端口访问不通

重点排查这几个地方：

1. 阿里云安全组是否放行 `80`
2. 服务器系统防火墙是否拦截 `80`
3. 宿主机上是否已有别的程序占用了 `80`

可用下面命令检查：

```bash
sudo ss -ltnp | grep :80
docker compose ps
docker compose logs --tail=100 nginx
```

## 备案通过后需要补的内容

拿到 ICP 备案号和公安备案号后，把首页底部两行文字改成正式编号即可。
