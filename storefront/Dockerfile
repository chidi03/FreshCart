# -----------------------------
# Stage 1: Build
# -----------------------------
FROM node:20-bookworm-slim AS builder

WORKDIR /app

# Copy dependency files first for layer caching
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application source
COPY tsconfig.json ./
COPY vite.config.ts ./
COPY vite-env.d.ts ./
COPY index.html ./
COPY src ./src

# Build the Vite application
RUN npm run build


# -----------------------------
# Stage 2: Production
# -----------------------------
FROM nginxinc/nginx-unprivileged:alpine AS production

# Copy the Vite build output into nginx's web root
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 8080
