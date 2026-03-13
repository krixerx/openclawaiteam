# Slack Setup Guide

## 1. Create Slack Apps (One Per Agent)

Each agent has its own Slack app so they appear as separate identities in Slack.

Go to https://api.slack.com/apps and create **3 separate apps**:

| App Name | Display Name | Agent |
|----------|-------------|-------|
| `emma-bot` | Emma (Project Lead) | Emma |
| `morgan-bot` | Morgan (Architect) | Morgan |
| `sean-bot` | Sean (Developer) | Sean |

### Required OAuth Scopes (Bot Token Scopes) — same for all 3 apps

- `chat:write` — Post messages
- `chat:write.customize` — Custom bot name/icon per message
- `channels:read` — View channel info
- `channels:history` — Read message history
- `channels:join` — Join channels programmatically
- `reactions:read` — Read reactions (for acknowledgement detection)
- `reactions:write` — Add reactions
- `users:read` — View user info

### Required OAuth Scopes (App-Level Token) — same for all 3 apps

- `connections:write` — Socket Mode connections

Enable **Socket Mode** for real-time message handling on each app.

### Event Subscriptions — same for all 3 apps

Subscribe to these bot events:
- `message.channels`
- `message.im`
- `app_mention`

## 2. Create Channels

Create these channels in your Slack workspace:

| Channel | Purpose |
|---------|---------|
| `#all-ai-team-1` | Main communication channel for all agents and PO |

Invite all 3 bots to `#all-ai-team-1`.

## 3. Channel Permissions

All agents read and write in the shared channel:

| Channel | Writers | Readers |
|---------|---------|---------|
| `#all-ai-team-1` | emma-bot, morgan-bot, sean-bot, Product Owner | emma-bot, morgan-bot, sean-bot, Product Owner |

## 4. Configure Tokens

Copy each app's Bot Token and App Token into your `.env` file:

```
EMMA_SLACK_BOT_TOKEN=xoxb-...
EMMA_SLACK_APP_TOKEN=xapp-...
MORGAN_SLACK_BOT_TOKEN=xoxb-...
MORGAN_SLACK_APP_TOKEN=xapp-...
SEAN_SLACK_BOT_TOKEN=xoxb-...
SEAN_SLACK_APP_TOKEN=xapp-...
```

Each agent's Docker container receives only its own tokens via environment variables.
