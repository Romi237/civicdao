# CivicDAO

Flutter client + Node.js/Express backend + MongoDB.

## VPS deployment

See [VPS_DEPLOYMENT.md](VPS_DEPLOYMENT.md).

## Local development

Backend:
```bash
cd backend
npm ci
cp .env.example .env
npm run dev
```

Docker (full stack):
```bash
cp .env.example .env
cd backend
printf "JWT_SECRET=%s\nJWT_REFRESH_SECRET=%s\n" "$(openssl rand -hex 48)" "$(openssl rand -hex 48)" > .env
cd ..
docker compose up -d --build
```
