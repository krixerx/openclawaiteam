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

chown -R node:node /home/node/.openclaw/bin /home/node/.openclaw/.gitconfig

# --- OpenClaw config: set requireMention=true, ackReactionScope=all ---
OPENCLAW_CONFIG="/home/node/.openclaw/openclaw.json"
if [ -f "$OPENCLAW_CONFIG" ]; then
    node -e "
    const fs = require('fs');
    const cfg = JSON.parse(fs.readFileSync('$OPENCLAW_CONFIG', 'utf8'));
    if (!cfg.channels) cfg.channels = {};
    if (!cfg.channels.slack) cfg.channels.slack = {};
    cfg.channels.slack.requireMention = false;
    if (!cfg.messages) cfg.messages = {};
    cfg.messages.ackReactionScope = 'all';
    fs.writeFileSync('$OPENCLAW_CONFIG', JSON.stringify(cfg, null, 2));
    console.log('[init] OpenClaw config updated');
    "
fi

echo "[init] Agent $AGENT_NAME setup complete"
