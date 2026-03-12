# OpenClaw AI Team

An autonomous AI development team powered by [OpenClaw](https://hub.docker.com/r/alpine/openclaw) agents that communicate and collaborate via Slack. Three specialized AI agents — a project lead, an architect, and a developer — work together to deliver software tasks assigned by a human Product Owner.

## Architecture

```
                    +-----------+
                    |  Product  |
                    |   Owner   |
                    |  (human)  |
                    +-----+-----+
                          |
                    Slack messages
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
            +-----+-----+  +-----+-----+
            |   Slack   |  | Bitbucket |
            | Workspace |  | Repos     |
            +-----------+  +-----------+
```

### Agents

| Agent | Role | Responsibilities |
|-------|------|-----------------|
| **Emma** | Project Lead | Receives tasks from PO, decomposes into sub-tasks, assigns work to Morgan and Sean, tracks progress, reports completion |
| **Morgan** | Architect | Produces design documents and ADRs, reviews PRs for design compliance |
| **Sean** | Developer & QA | Implements features per Morgan's designs, writes tests, opens PRs |

### Tech Stack

- **Agent Runtime**: [OpenClaw](https://hub.docker.com/r/alpine/openclaw) (alpine/openclaw Docker image)
- **LLM**: OpenAI GPT-4.1-mini (via OpenAI API)
- **Communication**: Slack (Socket Mode)
- **Source Control**: Bitbucket
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
   - `emmaailead@proton.me` (or your own naming)
   - `morganaiarch@proton.me`
   - `seanaidev@proton.me`
2. Save the credentials securely — never commit them to the repo

### 3. Set up Slack

#### Create a Slack workspace

1. Go to [slack.com](https://slack.com) and create a new workspace
2. Create a channel (e.g. `#all-ai-team-1`) for team communication
3. Invite the agent email addresses to the workspace

#### Create a Slack App

1. Go to [api.slack.com/apps](https://api.slack.com/apps) and click **Create New App** > **From scratch**
2. Name it (e.g. "AI Team 1") and select your workspace
3. **Enable Socket Mode** (left sidebar) — generate an App-Level Token (`xapp-...`)
4. Go to **OAuth & Permissions** and add these Bot Token Scopes:
   - `chat:write`
   - `channels:read`
   - `channels:history`
   - `reactions:read`
   - `reactions:write`
   - `users:read`
5. Go to **Event Subscriptions** — enable it and subscribe to these bot events:
   - `message.channels`
   - `message.im`
   - `app_mention`
6. **Install App to Workspace** — copy the Bot User OAuth Token (`xoxb-...`)
7. In your Slack channel, invite the bot: `/invite @YourBotName`

Add both tokens to `.env`:
```
SLACK_BOT_TOKEN=xoxb-your-token
SLACK_APP_TOKEN=xapp-your-token
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

### 7. Configure agents (first time only)

After the containers start, configure each agent's model and Slack group policy:

```bash
# Set the LLM model
docker exec openclaw-emma sh -c 'openclaw models set openai/gpt-4.1-mini'
docker exec openclaw-morgan sh -c 'openclaw models set openai/gpt-4.1-mini'
docker exec openclaw-sean sh -c 'openclaw models set openai/gpt-4.1-mini'

# Allow the bot to respond in channels (not just DMs)
docker exec openclaw-emma sh -c 'openclaw config set channels.slack.groupPolicy open'
docker exec openclaw-morgan sh -c 'openclaw config set channels.slack.groupPolicy open'
docker exec openclaw-sean sh -c 'openclaw config set channels.slack.groupPolicy open'

# Restart to apply
docker compose restart openclaw-emma openclaw-morgan openclaw-sean
```

These settings are persisted in Docker volumes and survive restarts.

## Usage

Talk to the agents in Slack by mentioning the bot:

```
@YourBotName build a REST API for user management
```

The Product Owner (you) gives tasks. Emma decomposes them, assigns architecture work to Morgan and design-approved implementation to Sean.

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
├── config/
│   ├── slack/           # Slack channel config
│   ├── grafana/         # Grafana dashboards and provisioning
│   ├── loki/            # Loki log aggregation config
│   ├── promtail/        # Promtail log shipper config
│   ├── loop-detection.md
│   └── po-commands.md
├── docker-compose.yml
├── .env.example
└── .env                 # Your local config (gitignored)
```

## Monitoring

- **Grafana**: http://localhost:3000 (default: admin/admin)
  - View agent logs aggregated by Loki
- **Agent logs**: `docker logs openclaw-emma --tail 50`

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

- All three agents share one Slack bot token, so they appear as the same bot identity. They all respond to every message in the channel.
- Groq's free tier has a 6,000 TPM limit — too low for the agent system prompts (~13k tokens). Use OpenAI or upgrade Groq.
- Agent identity files (IDENTITY.md, BRAIN.md, WORKFLOWS.md) are mounted read-only. Changes require a container restart.
