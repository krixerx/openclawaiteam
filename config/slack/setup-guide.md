# Slack Setup Guide

## 1. Create Slack App

Go to https://api.slack.com/apps and create a new app for your workspace.

### Bot Users

Create three bot users within the app (or create three separate apps):
- `emma-bot` — Project Lead
- `morgan-bot` — Architect
- `sean-bot` — Developer & QA

### Required OAuth Scopes (Bot Token Scopes)

- `chat:write` — Post messages
- `channels:read` — View channel info
- `channels:history` — Read message history
- `reactions:read` — Read reactions (for acknowledgement detection)
- `reactions:write` — Add reactions
- `users:read` — View user info

### Required OAuth Scopes (App-Level Token)

- `connections:write` — Socket Mode connections

Enable **Socket Mode** for real-time message handling.

## 2. Create Channels

Create these 6 channels in your Slack workspace:

| Channel | Purpose |
|---------|---------|
| `#po-commands` | PO issues tasks, STOP commands, overrides |
| `#pm-tasks` | Emma posts assignments, progress, blockers |
| `#architecture` | Morgan posts design decisions, ADRs, reviews |
| `#dev-updates` | Sean posts PR links, test results, build status |
| `#general` | Cross-team discussion, announcements |
| `#loop-alerts` | Loop detection alerts — PO approval required |

## 3. Channel Permissions

Invite the bots to their respective channels:

| Channel | Writers | Readers |
|---------|---------|---------|
| `#po-commands` | Product Owner | Emma, Morgan, Sean |
| `#pm-tasks` | Emma | Morgan, Sean, PO |
| `#architecture` | Morgan | Emma, Sean, PO |
| `#dev-updates` | Sean | Emma, Morgan, PO |
| `#general` | All agents | All |
| `#loop-alerts` | Any agent (auto) | Product Owner |

## 4. Configure Tokens

Copy the Bot Token and App Token for each bot into your `.env` file:

```
EMMA_SLACK_BOT_TOKEN=xoxb-...
EMMA_SLACK_APP_TOKEN=xapp-...
MORGAN_SLACK_BOT_TOKEN=xoxb-...
MORGAN_SLACK_APP_TOKEN=xapp-...
SEAN_SLACK_BOT_TOKEN=xoxb-...
SEAN_SLACK_APP_TOKEN=xapp-...
```
