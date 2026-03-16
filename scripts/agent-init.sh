#!/bin/sh
# Agent init script — runs as root in init containers
# Sets up workspace files, git credentials, Bitbucket CLI, and OpenClaw config
# All persistent files are stored on the state volume (/home/node/.openclaw)

AGENT_NAME="$1"
AGENT_EMAIL="$2"

echo "[init] Setting up agent: $AGENT_NAME ($AGENT_EMAIL)"

# --- Workspace files ---
chown -R node:node /home/node/.openclaw
mkdir -p /home/node/.openclaw/workspace
cp /tmp/agent/IDENTITY.md /home/node/.openclaw/workspace/IDENTITY.md
cp /tmp/agent/BRAIN.md /home/node/.openclaw/workspace/BRAIN.md
cp /tmp/agent/WORKFLOWS.md /home/node/.openclaw/workspace/WORKFLOWS.md
chown -R node:node /home/node/.openclaw/workspace

# --- Patch OpenClaw framework files so agent reads IDENTITY.md at startup ---
WORKSPACE="/home/node/.openclaw/workspace"

# Remove BOOTSTRAP.md — agents are already set up, this causes confusion
rm -f "$WORKSPACE/BOOTSTRAP.md"

# Overwrite SOUL.md — this is the FIRST file the agent reads on every session
cat > "$WORKSPACE/SOUL.md" << 'SOULEOF'
# SOUL.md - Who You Are

Read `IDENTITY.md` RIGHT NOW. It contains your name, role, responsibilities, and communication rules.
You MUST follow every instruction in IDENTITY.md — it is your primary directive.

## Critical Rules (also in IDENTITY.md — read that file for full details)

- You are part of a 3-agent team: Emma (lead), Morgan (architect), Sean (developer)
- Each agent runs in its own container — they are ALREADY RUNNING
- To talk to other agents, use the shell command: `msg-send <name> "subject" "body"`
- To check for messages from other agents: `msg-check`
- NEVER use sessions.resolve, sessions.create, sessions.spawn, or any ACP session commands
- NEVER try to start or spawn agent sessions — the other agents are already online
- NEVER ask for agent IDs or session IDs — just use msg-send
- ALWAYS post status updates to Slack for PO visibility
- To post to Slack, use the message tool with target: channel:C0AKHTG1M5M (this is #all-ai-team-1)
- NEVER send a Slack message without specifying target channel:C0AKHTG1M5M — it will fail without it

## Behavior

- Be direct and concise — skip filler words
- Be resourceful — read files, check context, search before asking
- When given a task, act immediately — do not ask for permission to communicate with teammates
SOULEOF

# Patch AGENTS.md to include IDENTITY.md in session startup
if [ -f "$WORKSPACE/AGENTS.md" ]; then
    sed -i 's/1\. Read `SOUL.md`.*/1. Read `SOUL.md` — core rules\n1a. Read `IDENTITY.md` — your role, responsibilities, and communication rules (MANDATORY)/' "$WORKSPACE/AGENTS.md"
    echo "[init] Patched AGENTS.md startup routine"
fi

# Set USER.md to describe the PO
cat > "$WORKSPACE/USER.md" << 'USEREOF'
# USER.md - Your Product Owner (PO)

- **Name**: The Product Owner (PO)
- **How to reach**: Slack channel #all-ai-team-1
- **Role**: Gives tasks, makes decisions, has supreme authority
- **What they want**: Status updates in Slack for every action you take
USEREOF

chown -R node:node "$WORKSPACE"

# --- Memory directory ---
mkdir -p /app/memory
chown node:node /app/memory

# --- Store scripts and git config on state volume (persisted) ---
mkdir -p /home/node/.openclaw/bin

# Bitbucket API wrapper
cat > /home/node/.openclaw/bin/bb << 'SCRIPT'
#!/bin/sh
curl -s -u "$BITBUCKET_USERNAME:$BITBUCKET_APP_PASSWORD" "https://api.bitbucket.org/2.0/$1"
SCRIPT
chmod +x /home/node/.openclaw/bin/bb

# Git config (stored on volume) — uses credential store with file on volume
cat > /home/node/.openclaw/.gitconfig << EOF
[user]
	name = $AGENT_NAME
	email = $AGENT_EMAIL
[credential]
	helper = store --file=/home/node/.openclaw/.git-credentials
EOF

# Profile script sourced on container start to set up PATH and gitconfig
cat > /home/node/.openclaw/bin/env-setup.sh << 'SCRIPT'
export PATH="/home/node/.openclaw/bin:$PATH"
export GIT_CONFIG_GLOBAL="/home/node/.openclaw/.gitconfig"
SCRIPT

# Redis messaging script + shell wrappers
cp /tmp/scripts/redis-msg.mjs /home/node/.openclaw/bin/redis-msg.mjs

cat > /home/node/.openclaw/bin/msg-send << 'SCRIPT'
#!/bin/sh
node /home/node/.openclaw/bin/redis-msg.mjs send "$@"
SCRIPT
chmod +x /home/node/.openclaw/bin/msg-send

cat > /home/node/.openclaw/bin/msg-check << 'SCRIPT'
#!/bin/sh
node /home/node/.openclaw/bin/redis-msg.mjs check
SCRIPT
chmod +x /home/node/.openclaw/bin/msg-check

cat > /home/node/.openclaw/bin/msg-history << 'SCRIPT'
#!/bin/sh
node /home/node/.openclaw/bin/redis-msg.mjs history "$@"
SCRIPT
chmod +x /home/node/.openclaw/bin/msg-history

chown -R node:node /home/node/.openclaw/bin /home/node/.openclaw/.gitconfig

# --- OpenClaw config: create or patch ---
# Create the config BEFORE OpenClaw first starts, so it doesn't default to Anthropic
OPENCLAW_CONFIG="/home/node/.openclaw/openclaw.json"
cat > "$OPENCLAW_CONFIG" << 'CFGEOF'
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai/gpt-4.1-mini"
      },
      "compaction": {
        "mode": "safeguard"
      },
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      }
    }
  },
  "messages": {
    "ackReactionScope": "all"
  },
  "commands": {
    "native": "auto",
    "nativeSkills": "auto",
    "restart": true,
    "ownerDisplay": "raw"
  },
  "channels": {
    "slack": {
      "mode": "socket",
      "webhookPath": "/slack/events",
      "enabled": true,
      "userTokenReadOnly": true,
      "groupPolicy": "open",
      "streaming": "partial",
      "nativeStreaming": true,
      "requireMention": true
    }
  }
}
CFGEOF
chown node:node "$OPENCLAW_CONFIG"
echo "[init] OpenClaw config created with openai/gpt-4.1-mini"

echo "[init] Agent $AGENT_NAME setup complete"
