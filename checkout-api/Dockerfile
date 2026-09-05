# -----------------------------
# Stage 1: Build
# -----------------------------
FROM node:20-bookworm-slim AS builder

WORKDIR /app

# Copy dependency files first.
# Docker can reuse this layer when application code changes.
COPY package*.json ./

# Install all dependencies, including dev dependencies
# required for the TypeScript build.
RUN npm ci

# Copy application source and configuration
COPY tsconfig.json ./
COPY src ./src

# Compile TypeScript
RUN npm run build


# -----------------------------
# Stage 2: Production
# -----------------------------
FROM node:20-alpine AS production

RUN apk upgrade --no-cache

WORKDIR /app

# Create a non-root user
RUN addgroup -S appgroup \
    && adduser -S appuser -G appgroup

# Copy dependency files first
COPY package*.json ./


# Install production dependencies, then remove package managers
# that are not needed by the running API.
RUN npm ci --omit=dev \
    && npm cache clean --force \
    && rm -rf /usr/local/lib/node_modules/npm \
        /usr/local/lib/node_modules/corepack \
        /usr/local/bin/npm \
        /usr/local/bin/npx \
        /usr/local/bin/corepack \
        /opt/yarn-v1.22.22 \
        /usr/local/bin/yarn \
        /usr/local/bin/yarnpkg


# Copy only the compiled application
COPY --from=builder /app/dist ./dist

# Give the non-root user ownership of the application
RUN chown -R appuser:appgroup /app

# Run as non-root
USER appuser

# API port
EXPOSE 3000

# Start the compiled application
CMD ["node", "dist/index.js"]
