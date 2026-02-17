# OpenClaw Container Configuration
FROM alpine/openclaw:main

# Expose the gateway port
EXPOSE 18789

# Copy pre-configured openclaw.json with gateway.bind = "lan"
# This allows the container to accept connections from the host
# Use --chown to set ownership during copy (no need for separate RUN chown)
COPY --chown=node:node openclaw.json /home/node/.openclaw/openclaw.json
