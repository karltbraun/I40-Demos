# =============================================================================
# LineFeed Simulator — I40 Demo Producer
# Python/uv based; publishes production metrics to an MQTT broker.
# =============================================================================

FROM python:3.12-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Install dependencies first for layer cache efficiency
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

# Copy application source
COPY main.py config.toml ./
COPY simulator/ ./simulator/

# Sync again to install the project itself
RUN uv sync --frozen --no-dev

# Install container helpers
COPY entrypoint.sh /entrypoint.sh
COPY lfs-restart /usr/local/bin/lfs-restart
RUN chmod +x /entrypoint.sh /usr/local/bin/lfs-restart

# Create log directory (bind mount will overlay this at runtime)
RUN mkdir -p /logs

ENTRYPOINT ["/entrypoint.sh"]
