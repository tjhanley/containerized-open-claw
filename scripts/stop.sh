#!/bin/bash

# OpenClaw Container Stop Script

set -e

CONTAINER_NAME="norm"

echo "🛑 Stopping OpenClaw container..."

# Check if container exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    # Stop the container
    echo "⏸️  Stopping container..."
    docker stop "${CONTAINER_NAME}" 2>/dev/null || true

    # Remove the container
    echo "🗑️  Removing container..."
    docker rm "${CONTAINER_NAME}" 2>/dev/null || true

    echo "✅ Container stopped and removed successfully!"
else
    echo "⚠️  Container '${CONTAINER_NAME}' not found."
fi
