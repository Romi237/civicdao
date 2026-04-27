# CivicDAO Backend — Dockerfile
# Multi-stage: install deps in builder, run in slim image

# Stage 1: install dependencies
FROM node:20-alpine AS deps
WORKDIR /app
COPY backend/package*.json ./
RUN npm ci --omit=dev

# Stage 2: runtime — small and secure
FROM node:20-alpine AS runtime

# Non-root user for security
RUN addgroup -S civicdao && adduser -S civicdao -G civicdao

WORKDIR /app

# Copy only what we need
COPY --from=deps /app/node_modules ./node_modules
COPY backend/server.js ./
COPY backend/dds.js ./

RUN chown -R civicdao:civicdao /app
USER civicdao

EXPOSE 3000

# Kubernetes uses this to know when the container is healthy
HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "server.js"]