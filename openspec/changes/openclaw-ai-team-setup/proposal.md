## Why

The project needs a fully containerized, AI-powered software team built on OpenClaw where three autonomous agents (Emma - Project Lead, Morgan - Architect, Sean - Developer & QA) collaborate through Slack, coordinate via Bitbucket, and are supervised by a human Product Owner. All models run locally via Ollama at zero token cost, and agents operate in isolated Docker containers with strict security boundaries. This enables autonomous software development with human oversight while keeping infrastructure costs minimal.

## What Changes

- Stand up a Docker Compose stack with 3 OpenClaw agent containers (Emma, Morgan, Sean), a shared Ollama instance, Portainer, Loki, and Grafana
- Configure each agent with a unique identity (IDENTITY.md), role-specific system prompts, and isolated memory volumes
- Create Slack bots (emma-bot, morgan-bot, sean-bot) and wire them to dedicated channels (#po-commands, #pm-tasks, #architecture, #dev-updates, #general, #loop-alerts)
- Create Bitbucket service accounts with scoped app passwords for each agent and install the Bitbucket skill for PR workflows
- Implement loop detection and circuit-breaker logic that pauses agents and escalates to the Product Owner via #loop-alerts
- Implement Product Owner control commands (STOP, PAUSE, OVERRIDE, RESUME, STATUS) routed through #po-commands
- Set up Loki + Grafana dashboards for log aggregation and monitoring across all agent containers

## Capabilities

### New Capabilities
- `docker-infrastructure`: Docker Compose stack definition with all services, networking, volumes, and isolation rules
- `agent-identity`: Per-agent IDENTITY.md files, system prompts, model assignments, and memory namespace configuration
- `slack-integration`: Slack bot setup, channel wiring, message routing, and communication protocols between agents and PO
- `bitbucket-workflow`: Bitbucket service accounts, app passwords, PR creation/review skill installation, and end-to-end PR workflow
- `loop-detection`: Loop trigger detection, circuit-breaker behavior, agent explanation format, and PO escalation flow
- `po-controls`: Product Owner command handling (STOP, PAUSE, OVERRIDE, RESUME, STATUS) with audit logging
- `observability`: Loki log aggregation, Grafana dashboards, and container monitoring setup

### Modified Capabilities

## Impact

- **Infrastructure**: New Docker Compose stack with 7+ services; requires host with 16-24 GB VRAM for local LLM inference
- **External services**: Slack workspace with 6 channels and 3 bot integrations; Bitbucket workspace with 3 service accounts
- **Security**: Strict container isolation (no Docker socket mounting, no host networking), secrets via Docker secrets/.env files, prompt injection mitigations in system prompts
- **Dependencies**: OpenClaw (latest), Ollama, Qwen3-Coder (8b/32b), Docker Compose, Slack API, Bitbucket API
