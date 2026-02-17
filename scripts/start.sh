#!/bin/bash

# OpenClaw Container Start Script

set -e

CONTAINER_NAME="norm"
IMAGE_NAME="openclaw-norm"
PORT="18789"

# Load or create .env file
ENV_FILE="$(dirname "$0")/../.env"

if [ -f "$ENV_FILE" ]; then
    echo "📄 Loading environment from .env file..."
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "📝 No .env file found, generating new token..."
    NEW_TOKEN=$(openssl rand -hex 32)
    echo "OPENCLAW_GATEWAY_TOKEN=$NEW_TOKEN" > "$ENV_FILE"
    echo "✅ Created .env with new gateway token"
    export OPENCLAW_GATEWAY_TOKEN="$NEW_TOKEN"
fi

echo "🚀 Starting OpenClaw container..."

# Verify token is set
if [ -z "$OPENCLAW_GATEWAY_TOKEN" ]; then
    echo "❌ Error: Failed to load or generate token"
    exit 1
fi

echo "✅ Using gateway token from .env"

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "⚠️  Container '${CONTAINER_NAME}' already exists. Stopping and removing..."
    docker stop "${CONTAINER_NAME}" 2>/dev/null || true
    docker rm "${CONTAINER_NAME}" 2>/dev/null || true
fi

# Build the image
echo "🔨 Building Docker image..."
cd "$(dirname "$0")/.."
docker build -t "${IMAGE_NAME}" .

# Run the container
echo "🏃 Running container..."
docker run -d \
    --name "${CONTAINER_NAME}" \
    -p "${PORT}:${PORT}" \
    -e "OPENCLAW_GATEWAY_TOKEN=${OPENCLAW_GATEWAY_TOKEN}" \
    "${IMAGE_NAME}"

echo "✅ Container started successfully!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 OpenClaw Control UI (with token pre-filled):"
echo ""
echo "   http://localhost:${PORT}/?gatewayUrl=ws://localhost:${PORT}&token=${OPENCLAW_GATEWAY_TOKEN}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Copy the URL above and paste it into your browser."
echo "The token will be automatically configured!"
echo ""
echo "🔑 Manual token (if needed): ${OPENCLAW_GATEWAY_TOKEN}"
echo ""
echo "To view logs: docker logs -f ${CONTAINER_NAME}"
echo "To stop: ./scripts/stop.sh"
