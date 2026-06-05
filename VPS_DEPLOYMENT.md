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
cd civicdao
```

### Step 4 — Generate backend secrets
```bash
cd backend
node dds.js
cd ..
```

### Step 5 — Start everything
```bash
docker compose up -d
```

### Step 6 — Verify it is running
```bash
curl http://localhost:3000/health
# Expected: {"status":"ok","db":"connected"}
```

### Step 7 — Check Prometheus metrics
```bash
curl http://localhost:9090
# Open in browser: http://YOUR_VPS_IP:9090
```

### Step 8 — Open Grafana
Open in browser: `http://YOUR_VPS_IP:3001`
Login: admin / admin

---

## Update the Flutter app to point at your VPS

Once deployed, open `.env` and change:
```
API_BASE_URL=http://YOUR_VPS_IP:3000/api
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
| 3000 | Backend API          |
| 9090 | Prometheus           |
| 3001 | Grafana              |
| 27017| MongoDB (keep closed)|

Open ports with:
```bash
ufw allow 80
ufw allow 3000
ufw allow 9090
ufw allow 3001
ufw enable
```
