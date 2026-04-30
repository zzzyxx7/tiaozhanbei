# Site Deploy

This repo is wired for HTTPS on:

- `https://zzzyxx.cn`
- `https://www.zzzyxx.cn`

The mini program frontend is configured to call:

- `https://www.zzzyxx.cn`

## Required certificate files

Place these files in the repo root on the server:

- `www.zzzyxx.cn.pem`
- `www.zzzyxx.cn.key`

`docker compose` mounts them into the Nginx container automatically.

## Server deployment

### 1. Upload or update the repo

```bash
cd /opt/rule-backend
git pull origin main
```

If your branch is not `main`, replace it with the correct branch name.

### 2. Copy the certificate files to the server repo root

```bash
scp www.zzzyxx.cn.pem root@YOUR_SERVER_IP:/opt/rule-backend/
scp www.zzzyxx.cn.key root@YOUR_SERVER_IP:/opt/rule-backend/
```

### 3. Start or rebuild containers

```bash
cd /opt/rule-backend
docker compose up -d --build
```

### 4. Open required ports

In Alibaba Cloud security group and OS firewall, allow:

- `80/tcp`
- `443/tcp`
- `8080/tcp` (optional, only for direct backend debug)

### 5. Verify DNS

Make sure both records point to `8.136.46.14`:

- `@` -> `8.136.46.14`
- `www` -> `8.136.46.14`

## Verification

On the server:

```bash
docker compose ps
docker compose logs --tail=100 nginx
docker compose logs --tail=100 rule-backend
curl -I http://127.0.0.1
curl -I https://127.0.0.1 -k
curl https://127.0.0.1/v3/api-docs -k
```

From your own browser:

```text
https://zzzyxx.cn
https://www.zzzyxx.cn
https://www.zzzyxx.cn/v3/api-docs
```

## If HTTPS does not work

Check these first:

1. Port `443` is open in the Alibaba Cloud security group
2. The server firewall is not blocking `443`
3. The certificate files exist in `/opt/rule-backend`
4. Docker mounted the files successfully

Useful commands:

```bash
sudo ss -ltnp | grep :443
docker compose ps
docker compose logs --tail=100 nginx
docker exec -it rule-nginx ls -l /etc/nginx/ssl
```
