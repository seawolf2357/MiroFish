# ============================================================
# MiroFish - Hugging Face Space Docker Image (Optimized)
# ============================================================
# Multi-stage build: frontend build → production runtime
# ============================================================

# --- Stage 1: Build frontend ---
FROM node:22-slim AS frontend-builder

WORKDIR /app

# Copy frontend dependency files
COPY frontend/package.json frontend/package-lock.json ./frontend/

# Install frontend dependencies
RUN cd frontend && npm ci --prefer-offline

# Copy frontend source + locales (needed for i18n build)
COPY frontend/ ./frontend/
COPY locales/ ./locales/

# Build Vue app to /app/frontend/dist
RUN cd frontend && npm run build

# --- Stage 2: Production runtime ---
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     build-essential \
     curl \
  && rm -rf /var/lib/apt/lists/*

# Copy uv package manager
COPY --from=ghcr.io/astral-sh/uv:0.9.26 /uv /uvx /bin/

# Create non-root user for HF Space security
RUN useradd -m -u 1000 user
WORKDIR /app

# Copy Python dependency files and install
COPY backend/pyproject.toml backend/uv.lock ./backend/
RUN cd backend && uv sync --frozen --no-dev

# Copy backend source
COPY backend/ ./backend/

# Copy built frontend from stage 1
COPY --from=frontend-builder /app/frontend/dist ./frontend/dist

# Copy locales for backend i18n
COPY locales/ ./locales/

# Create uploads directory with correct permissions
RUN mkdir -p /app/backend/uploads && chown -R user:user /app

# Switch to non-root user
USER user

# HF Space expects port 7860
ENV FLASK_HOST=0.0.0.0
ENV FLASK_PORT=7860
ENV FLASK_DEBUG=False

EXPOSE 7860

# Start Flask in production mode (serves both API + frontend static files)
CMD ["sh", "-c", "cd /app/backend && uv run python run.py"]
