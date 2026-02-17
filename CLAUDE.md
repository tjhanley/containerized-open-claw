# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker wrapper for OpenClaw that provides a simple, secure way to run OpenClaw in a container with proper port configuration and token-based authentication. The setup extends `alpine/openclaw:main` and adds configuration for LAN binding and authentication.

## Essential Commands

### Starting and Stopping

```bash
# Start the OpenClaw container (auto-generates .env if missing)
./scripts/start.sh

# Stop and remove the container
./scripts/stop.sh

# View container logs
docker logs -f norm
```

**Important**: The start script will automatically:
1. Generate `.env` with a secure token if it doesn't exist
2. Build the Docker image (`openclaw-norm`)
3. Start the container with port mapping
4. Display a tokenized URL ready to paste into your browser

### Docker Operations

```bash
# Check container status
docker ps

# Verify port mapping
docker port norm

# Rebuild after Dockerfile changes
docker build -t openclaw-norm .
```

## Architecture

### Key Components

- **Dockerfile**: Extends `alpine/openclaw:main`, exposes port 18789, and copies pre-configured `openclaw.json` with proper ownership
- **openclaw.json**: Gateway configuration with:
  - `gateway.bind: "lan"` - Allows Docker port forwarding (0.0.0.0)
  - `gateway.auth.mode: "token"` - Token-based authentication
  - `gateway.controlUi.allowInsecureAuth: true` - Required for localhost HTTP access
  - `trustedProxies` - Docker network ranges for proxy support
- **scripts/start.sh**: Orchestrates token generation, image building, and container startup
- **scripts/stop.sh**: Stops and removes the container
- **.env**: Contains `OPENCLAW_GATEWAY_TOKEN` (git-ignored, auto-generated)

### Configuration Flow

1. `start.sh` loads or creates `.env` with `OPENCLAW_GATEWAY_TOKEN`
2. Token is passed to container via environment variable
3. `openclaw.json` is copied into container at `/home/node/.openclaw/openclaw.json`
4. Container runs with port `18789` mapped to host

### Port Configuration

Default port is `18789`, defined in `scripts/start.sh` as the `PORT` variable. To change:
1. Edit `PORT` variable in `scripts/start.sh`
2. Update `EXPOSE` directive in `Dockerfile` if needed

### Security Notes

- `.env` is git-ignored and must never be committed
- Token is generated using `openssl rand -hex 32`
- Access must be via `localhost` or `127.0.0.1` (browsers recognize these as secure contexts)
- Do not use other hostnames like `lvh.me` - they will fail with "requires HTTPS or localhost" error

## Access Pattern

After running `./scripts/start.sh`, use the displayed tokenized URL:
```
http://localhost:18789/?gatewayUrl=ws://localhost:18789&token=YOUR_TOKEN
```

The Control UI is the main entry point for accessing OpenClaw features including the canvas.

## Troubleshooting

- **Connection Refused**: Check container is running (`docker ps`), verify port mapping, check logs
- **Unauthorized Errors**: Use the Control UI at root path, not internal endpoints
- **"requires HTTPS or localhost"**: Only access via `localhost` or `127.0.0.1`, not other hostnames
