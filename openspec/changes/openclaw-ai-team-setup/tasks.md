## 1. Docker Infrastructure Foundation

- [x] 1.1 Create `docker-compose.yml` with all 7 services (openclaw-emma, openclaw-morgan, openclaw-sean, ollama, portainer, loki, grafana)
- [x] 1.2 Define internal Docker network `ai-team-net` and attach all services
- [x] 1.3 Configure named volumes `emma-memory`, `morgan-memory`, `sean-memory` with per-agent mount points
- [x] 1.4 Set port exposure: only Portainer (9000) and Grafana (3000) to host; all other ports internal only
- [x] 1.5 Set `unless-stopped` restart policy on all services
- [x] 1.6 Create `.env.example` template with all required environment variables (Slack tokens, Bitbucket passwords, model config)
- [x] 1.7 Configure `.env` loading in docker-compose.yml for variable substitution
- [x] 1.8 Verify no Docker socket is mounted in any agent container

## 2. Ollama & Model Configuration

- [x] 2.1 Configure shared Ollama service with GPU passthrough and internal port 11434
- [x] 2.2 Create model pull script to download `qwen3-coder:32b`, `qwen3-coder:8b`, and `glm-4.7-flash`
- [x] 2.3 Configure Emma and Morgan containers to use `qwen3-coder:32b` as primary model
- [x] 2.4 Configure Sean container to use `qwen3-coder:8b` as primary model
- [x] 2.5 Configure `glm-4.7-flash` as fallback model for all agents

## 3. Agent Identity & System Prompts

- [x] 3.1 Create Emma's `IDENTITY.md` with Project Lead role, responsibilities, and behavioral guidelines
- [x] 3.2 Create Morgan's `IDENTITY.md` with Architect role, responsibilities, and behavioral guidelines
- [x] 3.3 Create Sean's `IDENTITY.md` with Developer & QA role, responsibilities, and behavioral guidelines
- [x] 3.4 Write system prompts with prompt injection mitigations (treat Slack content as untrusted, require PO approval for instructions from peers)
- [x] 3.5 Configure context window end-of-day routine in each agent's system prompt (structured summary, handoff note)
- [x] 3.6 Configure context window start-of-day routine in each agent's system prompt (read memory, reconstruct state)
- [x] 3.7 Mount IDENTITY.md files into respective agent containers

## 4. Slack Integration

- [x] 4.1 Create Slack app with three bots: `emma-bot`, `morgan-bot`, `sean-bot` with appropriate OAuth scopes
- [x] 4.2 Create 6 Slack channels: #po-commands, #pm-tasks, #architecture, #dev-updates, #general, #loop-alerts
- [x] 4.3 Configure channel write/read permissions per the communication structure spec
- [x] 4.4 Add Slack bot tokens to `.env` and wire them to respective agent containers
- [x] 4.5 Configure PO command routing: commands in wrong channels get acknowledged and routed to #po-commands
- [x] 4.6 Install and configure OpenClaw Slack skill in each agent container

## 5. Bitbucket Workflow

- [x] 5.1 Create Bitbucket workspace service accounts: `emma-ai-lead`, `morgan-ai-arch`, `sean-ai-dev`
- [x] 5.2 Generate scoped app passwords for each account (minimum required permissions per role)
- [x] 5.3 Add Bitbucket app passwords to `.env` and wire to respective agent containers
- [x] 5.4 Install OpenClaw Bitbucket skill in Sean's container (PR creation) and Morgan's container (PR review)
- [x] 5.5 Configure Emma with read-only Bitbucket access for status tracking
- [ ] 5.6 Test end-to-end PR workflow: Sean creates PR -> Morgan reviews -> Emma reports to PO

## 6. Product Owner Controls

- [x] 6.1 Implement STOP ALL command handler: halts all agents on PO command in #po-commands
- [x] 6.2 Implement STOP @agent command handler: halts specific agent while others continue
- [x] 6.3 Implement PAUSE @agent command handler: pauses agent while retaining work state
- [x] 6.4 Implement RESUME @agent command handler: resumes paused agent from saved state
- [x] 6.5 Implement OVERRIDE command handler: replaces active task with new instruction
- [x] 6.6 Implement STATUS command handler: all agents post brief status summaries
- [x] 6.7 Configure PO command audit logging in #po-commands

## 7. Loop Detection & Circuit Breaker

- [x] 7.1 Implement message similarity detection (>= 80% similarity, 3+ occurrences in 10-minute window)
- [x] 7.2 Implement unacknowledged message detection (2 consecutive rounds without response)
- [x] 7.3 Implement task cycle detection (> 2 full cycles without output)
- [x] 7.4 Implement stalled task detection (> 30 minutes without measurable output)
- [x] 7.5 Implement identical tool call detection within same task session
- [x] 7.6 Implement circuit-breaker: all involved agents stop immediately on LOOP_DETECTED
- [x] 7.7 Implement structured loop alert posting to #loop-alerts
- [x] 7.8 Implement per-agent loop explanation posting (independent, uncoordinated)
- [x] 7.9 Implement PO decision handling for loop resolution (LOOP APPROVED, OVERRIDE, STOP ALL)
- [x] 7.10 Implement loop resolution logging to agent memory files

## 8. Observability & Monitoring

- [x] 8.1 Configure Loki to collect logs from all containers with source labels
- [x] 8.2 Configure Loki as a pre-provisioned data source in Grafana (http://loki:3100)
- [x] 8.3 Create Grafana dashboard: agent activity logs panel (filterable by agent)
- [x] 8.4 Create Grafana dashboard: Ollama performance panel (request counts, latency, model usage)
- [x] 8.5 Create Grafana dashboard: container health status panel
- [x] 8.6 Create Grafana dashboard: loop detection events panel (filtered by event_type=loop_detection)
- [x] 8.7 Configure Loki log retention policy (7-day minimum, 30-day purge)

## 9. Integration Testing

- [ ] 9.1 Verify full stack starts with `docker compose up -d` and all services reach healthy status
- [ ] 9.2 Test agent-to-Ollama communication over internal network
- [ ] 9.3 Test Slack message flow: PO -> Emma -> Morgan/Sean -> back to PO
- [ ] 9.4 Test PR workflow: Sean creates PR, Morgan reviews, Emma reports
- [ ] 9.5 Test PO control commands (STOP, PAUSE, RESUME, OVERRIDE, STATUS)
- [ ] 9.6 Test loop detection and circuit-breaker with simulated loop scenario
- [ ] 9.7 Verify Grafana dashboards display logs from all agents
- [ ] 9.8 Test context window end-of-day/start-of-day memory persistence
