# CivicDAO — VPS Deployment Guide

## Quick deploy on a fresh Ubuntu 22.04 VPS

### Step 1 — Connect to your VPS
```bash
ssh root@YOUR_VPS_IP
```

### Step 2 — Install dependencies (one command)
```bash
curl -fsSL https://get.docker.com | sh
apt install -y docker-compose-plugin git
```

### Step 3 — Clone your repo
```bash
git clone https://github.com/Romi237/civicdao.git
cd civicdao/civicdao_new
```

### Step 4 — Create required env files
```bash
cd backend
printf "JWT_SECRET=%s\nJWT_REFRESH_SECRET=%s\n" "$(openssl rand -hex 48)" "$(openssl rand -hex 48)" > .env
cd ..

cp .env.example .env
```
Edit `.env` and set strong values for `MONGO_PASS` and `GRAFANA_PASS`.

### Step 5 — Start everything
```bash
docker compose up -d
```

### Step 6 — Verify it is running
```bash
curl http://localhost/health
# Expected: {"status":"ok","db":"connected"}
```

### Step 7 — Check Prometheus metrics
```bash
curl http://localhost:9090
```

### Step 8 — Open Grafana
Grafana is bound to localhost. Use an SSH tunnel:
```bash
ssh -L 3001:localhost:3001 -L 9090:localhost:9090 root@YOUR_VPS_IP
```
Then open:
`http://localhost:3001`

---

## Update the Flutter app to point at your VPS

Once deployed, open `assets/env/.env` and change:
```
API_BASE_URL=http://YOUR_VPS_IP/api
```

Then rebuild:
```bash
flutter run --release
```

---

## Recommended VPS providers (cheapest options)

| Provider      | Plan         | Price     | Link                        |
|---------------|--------------|-----------|-----------------------------|
| Hetzner       | CX22         | €4/month  | hetzner.com                 |
| DigitalOcean  | Basic Droplet| $6/month  | digitalocean.com            |
| Contabo       | VPS S        | €5/month  | contabo.com                 |
| Vultr         | Cloud Compute| $6/month  | vultr.com                   |

**Recommended: Hetzner CX22** — 2 vCPU, 4GB RAM, 40GB SSD, Ubuntu 22.04.
This is enough to run MongoDB + Backend + Nginx + Prometheus + Grafana.

---

## Ports that must be open in your firewall

| Port | Service              |
|------|----------------------|
| 80   | Nginx (HTTP)         |
| 443  | HTTPS (optional)     |

Open ports with:
```bash
ufw allow 80
ufw allow 443
ufw enable
```
