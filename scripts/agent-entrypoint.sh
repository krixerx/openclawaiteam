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

# Set up cron job to check Redis inbox (agent-to-agent communication)
CRON_FILE="/home/node/.openclaw/cron/jobs.json"
AGENT_NAME_LOWER=$(echo "$OPENCLAW_AGENT_NAME" | tr '[:upper:]' '[:lower:]')

if [ -n "$OPENCLAW_AGENT_NAME" ]; then
    if [ "$AGENT_NAME_LOWER" = "emma" ]; then
        CRON_MSG="Run the shell command: msg-check -- If there are messages, process them. If Morgan posted a design, review it and then run: msg-send sean Implementation-Task your-message. If Sean reports completion, verify on Bitbucket and report to the PO in Slack. Always post a status update to Slack using the message tool with target channel:C0AKHTG1M5M."
    elif [ "$AGENT_NAME_LOWER" = "morgan" ]; then
        CRON_MSG="Run the shell command: msg-check -- If there are messages, process them. If Emma assigned a design task, produce the design and run: msg-send emma Design-Complete your-design. Also run: msg-send sean Design-Document the-design. Always post a status update to Slack using the message tool with target channel:C0AKHTG1M5M."
    elif [ "$AGENT_NAME_LOWER" = "sean" ]; then
        CRON_MSG="Run the shell command: msg-check -- If there are messages, process them. If there is an implementation task with a design, implement it: clone the repo, make changes, commit and git push to Bitbucket. When done run: msg-send emma Implementation-Complete your-summary. Always post a status update to Slack using the message tool with target channel:C0AKHTG1M5M."
    fi

    mkdir -p /home/node/.openclaw/cron
    NOW_MS=$(date +%s)000
    cat > "$CRON_FILE" << ENDJSON
{
  "version": 1,
  "jobs": [
    {
      "id": "check-inbox-${AGENT_NAME_LOWER}",
      "name": "check-inbox",
      "description": "Check Redis inbox for messages from other agents",
      "enabled": true,
      "schedule": {"kind": "cron", "expr": "*/2 * * * *"},
      "sessionTarget": "isolated",
      "payload": {"kind": "agentTurn", "message": "${CRON_MSG}"},
      "delivery": {"mode": "none"},
      "state": {"nextRunAtMs": ${NOW_MS}}
    }
  ]
}
ENDJSON
fi

# Execute the original entrypoint
exec "$@"
