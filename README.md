# OpenClaw AI Team

An autonomous AI development team powered by [OpenClaw](https://hub.docker.com/r/alpine/openclaw) agents. Three specialized AI agents — a project lead, an architect, and a developer — work together to deliver software tasks assigned by a human Product Owner.

## Architecture

```
                    +-----------+
                    |  Product  |
                    |   Owner   |
                    |  (human)  |
                    +-----+-----+
                          |
                    Slack #all-ai-team-1
                          |
          +---------------+---------------+
          |               |               |
    +-----+-----+  +-----+-----+  +------+----+
    |   Emma    |  |  Morgan   |  |   Sean    |
    |  Project  |  | Architect |  | Developer |
    |   Lead    |  |           |  |   & QA    |
    +-----------+  +-----------+  +-----------+
     OpenClaw       OpenClaw       OpenClaw
     Container      Container      Container
          |               |               |
          +-------+-------+-------+-------+
                  |               |
          +-------+-----+  +-----+-----+
          |    Redis    |  | Bitbucket |
          | (messaging) |  |  (code)   |
          +-------------+  +-----------+
```

### Communication Flow

The agents use **two separate channels** for communication:

| Channel | Purpose | How |
|---------|---------|-----|
| **Redis** | Agent-to-agent messaging | `msg-send`, `msg-check` shell commands |
| **Slack** | PO visibility & commands | OpenClaw message tool → `channel:C0AKHTG1M5M` |

**Why not Slack for everything?** Slack bot-to-bot messages are not delivered. Agents cannot talk to each other via Slack — only the human PO can message agents there.

**Message flow for a typical task:**

1. PO posts task in Slack → Emma receives it
2. Emma sends design task to Morgan via Redis (`msg-send morgan ...`)
3. Morgan's cron picks it up, produces design, sends back via Redis (`msg-send emma ...`)
4. Emma approves, sends implementation task to Sean via Redis (`msg-send sean ...`)
5. Sean implements, pushes to Bitbucket main branch, notifies Emma via Redis
6. Each agent posts status updates to Slack at every step for PO visibility

**Redis messaging commands** (available on all agent containers):

```bash
msg-send <to> "<subject>" "<body>"   # Send a message to another agent
msg-check                             # Check inbox for new messages (pops & deletes)
msg-history [count]                   # View recent message history (default: 20)
```

Messages are stored in Redis lists (`inbox:<agent>` for queues, `msg:history` for the last 100 messages). A cron job on each agent runs `msg-check` every 2 minutes to poll for new messages.

### Agents

| Agent | Role | Responsibilities |
|-------|------|-----------------|
| **Emma** | Project Lead | Receives tasks from PO, decomposes into sub-tasks, assigns work to Morgan and Sean, tracks progress, reports completion |
| **Morgan** | Architect | Produces design documents and ADRs, reviews PRs for design compliance |
| **Sean** | Developer & QA | Implements features per Morgan's designs, writes tests, pushes to main branch |

### Tech Stack

- **Agent Runtime**: [OpenClaw](https://hub.docker.com/r/alpine/openclaw) (alpine/openclaw Docker image)
- **LLM**: OpenAI GPT-4.1-mini (via OpenAI API)
- **Agent-to-Agent Messaging**: Redis 7 (message queues via lists)
- **PO Communication**: Slack (Socket Mode, one app per agent)
- **Source Control**: Bitbucket (agents push directly to main)
- **Observability**: Grafana + Loki + Promtail (log aggregation)
- **Orchestration**: Docker Compose

## Prerequisites

- Docker Desktop
- An OpenAI API key ([platform.openai.com](https://platform.openai.com/api-keys))
- A Slack workspace

## Setup Guide

### 1. Clone and configure environment

```bash
git clone <repo-url>
cd OpenClawATeam
cp .env.example .env
```

Edit `.env` and fill in your API keys and credentials (see sections below).

### 2. Create email accounts for agents

Each agent needs its own email for service registrations (Slack invites, Bitbucket access, etc.). We use ProtonMail:

1. Go to [proton.me](https://proton.me) and create 3 free accounts:
   - `your-lead-agent@proton.me` (or your own naming)
   - `your-architect-agent@proton.me`
   - `your-developer-agent@proton.me`
2. Save the credentials securely — never commit them to the repo

### 3. Set up Slack

#### Create a Slack workspace

1. Go to [slack.com](https://slack.com) and create a new workspace
2. Create a channel (e.g. `#all-ai-team-1`) for team communication
3. Invite the agent email addresses to the workspace

#### Create Slack Apps (one per agent)

Create **3 separate Slack apps** so each agent has its own identity:

For each agent (emma-bot, morgan-bot, sean-bot):

1. Go to [api.slack.com/apps](https://api.slack.com/apps) and click **Create New App** > **From scratch**
2. Name it (e.g. "emma-bot", "morgan-bot", "sean-bot") and select your workspace
3. **Enable Socket Mode** (left sidebar) — generate an App-Level Token (`xapp-...`)
4. Go to **OAuth & Permissions** and add these Bot Token Scopes:
   - `chat:write`, `chat:write.customize`
   - `channels:read`, `channels:history`, `channels:join`
   - `reactions:read`, `reactions:write`
   - `users:read`
5. Go to **Event Subscriptions** — enable it and subscribe to these bot events:
   - `message.channels`
   - `message.im`
   - `app_mention`
6. **Install App to Workspace** — copy the Bot User OAuth Token (`xoxb-...`)
7. In your Slack channel, invite the bot: `/invite @BotName`

Add each agent's tokens to `.env`:
```
EMMA_SLACK_BOT_TOKEN=xoxb-emma-token
EMMA_SLACK_APP_TOKEN=xapp-emma-token
MORGAN_SLACK_BOT_TOKEN=xoxb-morgan-token
MORGAN_SLACK_APP_TOKEN=xapp-morgan-token
SEAN_SLACK_BOT_TOKEN=xoxb-sean-token
SEAN_SLACK_APP_TOKEN=xapp-sean-token
```

### 4. Set up Bitbucket

1. Create a Bitbucket workspace at [bitbucket.org](https://bitbucket.org)
2. Create user accounts for each agent (or use App Passwords)
3. Grant each agent read/write access to the repositories
4. Add credentials to `.env`

### 5. Get an OpenAI API key

1. Go to [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
2. Create a new API key
3. Add it to `.env`:
   ```
   OPENAI_API_KEY=sk-your-key
   ```

### 6. Start the stack

```bash
docker compose up -d
```

On first start, the init containers will set up each agent's workspace, git config, Redis messaging scripts, and OpenClaw configuration automatically.

### 7. Verify agents are online

```bash
# Check all containers are healthy
docker ps

# Verify Redis is running
docker exec redis redis-cli ping

# Test messaging between agents
docker exec openclaw-emma sh -c 'msg-send morgan "Test" "Hello from Emma"'
docker exec openclaw-morgan sh -c 'msg-check'
```

Then message each agent once in Slack to establish their channel session:
```
@emma-bot You are online. Read IDENTITY.md and SOUL.md now.
@morgan-bot You are online. Read IDENTITY.md and SOUL.md now.
@sean-bot You are online. Read IDENTITY.md and SOUL.md now.
```

## Usage

Talk to Emma in Slack by mentioning her bot:

```
@emma-bot In the ai-team-test-1 repo, add a contact form page. Morgan should design it, Sean should implement it.
```

Emma decomposes the task, assigns architecture to Morgan via Redis, reviews the design, then assigns implementation to Sean. Sean pushes directly to the main branch on Bitbucket. All agents post status updates to Slack so you can follow along.

### Inspecting agent messages

```bash
# View last 20 messages across all agents
docker exec openclaw-emma sh -c 'msg-history 20'

# Check a specific agent's pending inbox
docker exec redis redis-cli LRANGE inbox:morgan 0 -1

# View full message history in Redis
docker exec redis redis-cli LRANGE msg:history 0 -1
```

## Project Structure

```
OpenClawATeam/
├── agents/
│   ├── emma/           # Emma's identity, brain, and workflows
│   │   ├── IDENTITY.md
│   │   ├── BRAIN.md
│   │   └── WORKFLOWS.md
│   ├── morgan/         # Morgan's identity, brain, and workflows
│   └── sean/           # Sean's identity, brain, and workflows
├── scripts/
│   ├── agent-init.sh       # Init container: workspace setup, git config, messaging tools
│   ├── agent-entrypoint.sh # Runtime: cron setup, git credentials, config patching
│   └── redis-msg.mjs       # Redis messaging client (Node.js, no dependencies)
├── config/
│   ├── grafana/         # Grafana dashboards and provisioning
│   ├── loki/            # Loki log aggregation config
│   └── promtail/        # Promtail log shipper config
├── docker-compose.yml
├── .env.example
└── .env                 # Your local config (gitignored)
```

## Monitoring

- **Grafana**: http://localhost:3000 (default: admin/admin)
  - View agent logs aggregated by Loki
- **Agent logs**: `docker logs openclaw-emma --tail 50`
- **Redis messages**: `docker exec openclaw-emma sh -c 'msg-history'`

## LLM Model Options

The default model is `openai/gpt-4.1-mini` (good balance of cost, speed, and quality). Other options:

| Model | Provider | Notes |
|-------|----------|-------|
| `openai/gpt-4.1-mini` | OpenAI | Recommended. Cheap, fast, 1M context |
| `openai/gpt-4.1` | OpenAI | Higher quality, more expensive |
| `openai/gpt-4.1-nano` | OpenAI | Cheapest option |
| `groq/llama-3.3-70b-versatile` | Groq | Free tier, but low token limits |

To change a model:
```bash
docker exec openclaw-emma sh -c 'openclaw models set openai/gpt-4.1'
docker compose restart openclaw-emma
```

## Known Limitations

- **Slack bot-to-bot**: Slack does not deliver messages between bots. All agent-to-agent communication goes through Redis.
- **Cron polling**: Agents check their Redis inbox every 2 minutes via cron. This means a full Emma→Morgan→Sean round-trip has ~6 minutes of polling overhead.
- **Slack channel session**: Each agent must be @mentioned once in Slack before cron-triggered Slack posts will work (establishes the channel session context).
- **Groq free tier**: Has a 6,000 TPM limit — too low for agent system prompts (~13k tokens). Use OpenAI or upgrade Groq.
- **Identity changes**: Agent identity files (IDENTITY.md, BRAIN.md, WORKFLOWS.md) are mounted read-only. Changes require a container restart.
