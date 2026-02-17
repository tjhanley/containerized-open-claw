# OpenClaw Docker Setup

This directory contains a Dockerfile and management scripts for running OpenClaw in a container with proper port configuration.

## Quick Start

```bash
cd ~/Workspace/norm
./scripts/start.sh
```

**That's it!** The start script will:
1. Auto-generate `.env` with a secure token if it doesn't exist
2. Build and start the container
3. Display your gateway token to paste into the Control UI

The token is displayed when the container starts - copy it for the Control UI settings.

### Stop the container:
```bash
./scripts/stop.sh
```

### View logs:
```bash
docker logs -f norm
```

## What It Does

- **Dockerfile**: Extends `alpine/openclaw:main` and exposes port 18789
- **start.sh**: Builds the image and runs the container with port mapping
- **stop.sh**: Stops and removes the container

## Access

The `start.sh` script outputs a **tokenized URL** that automatically configures authentication:

```
http://localhost:18789/?gatewayUrl=ws://localhost:18789&token=YOUR_TOKEN
```

**Just copy and paste this URL into your browser** - no manual token entry needed!

⚠️ **Important**: Use `localhost` or `127.0.0.1` - not `lvh.me`. The Control UI requires a secure context, and browsers only recognize `localhost` and `127.0.0.1` as secure over HTTP.

The Control UI is the main entry point for accessing OpenClaw, including the canvas and all features.

## Configuration

### Port
The port is set to `18789` by default. To change it, edit the `PORT` variable in `scripts/start.sh`.

### Authentication
The container is configured with:
- **Gateway bind mode**: `lan` (0.0.0.0) - allows Docker port forwarding
- **Auth mode**: `token` - secure authentication
- **Token**: Set via `OPENCLAW_GATEWAY_TOKEN` in `.env` file

The token is passed to the container at runtime and must be entered in the Control UI settings on first use.

**Security**: The `.env` file is git-ignored to keep your token secure. Never commit it to version control.

## Troubleshooting

### Connection Refused
If you see "Connection Refused" in your browser:
1. Check the container is running: `docker ps`
2. Verify port mapping: `docker port norm`
3. Check logs: `docker logs norm`

### Unauthorized Errors
The Control UI at `http://localhost:18789/` handles authentication automatically. Don't access internal endpoints like `/__openclaw__/canvas/` directly in your browser.

### Error: "control ui requires HTTPS or localhost (secure context)"
This error appears when accessing via hostnames other than `localhost` or `127.0.0.1`. Always use:
- `http://localhost:18789/` (recommended)
- `http://127.0.0.1:18789/` (also works)

Browsers treat these as secure contexts even over HTTP, but don't recognize other domains like `lvh.me`.
