#!/bin/sh
# Agent entrypoint wrapper — sources env setup then runs the default entrypoint
# This ensures PATH includes /home/node/.openclaw/bin and git config is set

if [ -f /home/node/.openclaw/bin/env-setup.sh ]; then
    . /home/node/.openclaw/bin/env-setup.sh
fi

# Install Chromium if not present (needs root, but we run as node)
# Chromium is installed at runtime since it can't be persisted on the state volume
if ! command -v chromium >/dev/null 2>&1; then
    echo "[entrypoint] Chromium not found — it will be installed by the system"
fi

# Execute the original entrypoint
exec "$@"
