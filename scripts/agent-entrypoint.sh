#!/bin/sh
# Agent entrypoint wrapper — sources env setup then runs the default entrypoint
# This ensures PATH includes /home/node/.openclaw/bin and git config is set

if [ -f /home/node/.openclaw/bin/env-setup.sh ]; then
    . /home/node/.openclaw/bin/env-setup.sh
fi

# Write git credentials file from env vars (credentials available at runtime, not init time)
# Git uses BITBUCKET_GIT_USERNAME (Bitbucket username), API uses BITBUCKET_USERNAME (email)
if [ -n "$BITBUCKET_GIT_USERNAME" ] && [ -n "$BITBUCKET_APP_PASSWORD" ]; then
    echo "https://${BITBUCKET_GIT_USERNAME}:${BITBUCKET_APP_PASSWORD}@bitbucket.org" > /home/node/.openclaw/.git-credentials
    chmod 600 /home/node/.openclaw/.git-credentials
fi

# Install Chromium if not present (needs root, but we run as node)
# Chromium is installed at runtime since it can't be persisted on the state volume
if ! command -v chromium >/dev/null 2>&1; then
    echo "[entrypoint] Chromium not found — it will be installed by the system"
fi

# Execute the original entrypoint
exec "$@"
