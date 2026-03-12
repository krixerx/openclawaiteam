## Context

The project is greenfield — no existing infrastructure. We need to stand up a complete AI-powered software team using OpenClaw, where three agents collaborate autonomously on software tasks under human Product Owner supervision. All LLM inference runs locally via Ollama (zero API cost). Agents communicate via Slack and coordinate code changes through Bitbucket. Each agent runs in an isolated Docker container with persistent memory volumes.

Key constraints from the plan document:
- Minimum 64k token context window per agent
- 16-24 GB VRAM recommended for concurrent 3-agent operation
- No Docker socket mounting, no host networking
- All cross-agent communication flows through Slack only (no direct memory access)
- Product Owner has supreme authority over all agents at all times

## Goals / Non-Goals

**Goals:**
- Stand up a reproducible Docker Compose stack that runs all services with a single `docker compose up`
- Each agent has a distinct identity, role-specific system prompt, and isolated persistent memory
- Slack integration enables structured communication across defined channels
- Bitbucket integration enables the full PR workflow (create, review, merge)
- Loop detection prevents agents from entering unproductive feedback cycles
- Product Owner can control all agents via simple Slack commands
- Loki + Grafana provide centralized logging and monitoring

**Non-Goals:**
- Internet-connected LLM providers (all inference is local via Ollama)
- Auto-scaling or Kubernetes orchestration (single-host Docker Compose only)
- Multi-workspace or multi-team support (single team of 3 agents)
- Custom OpenClaw skill development (use existing skills from ClawHub)
- CI/CD pipeline integration (Bitbucket pipelines are out of scope for v1)

## Decisions

### D1: Single Ollama instance with request queuing vs. per-agent Ollama
**Decision**: Single shared Ollama container serving all 3 agents.
**Rationale**: Running 3 separate Ollama instances would require 3x VRAM. A shared instance with request queuing is recommended for hosts with 16-24 GB VRAM. Ollama handles concurrent requests natively.
**Alternative**: Per-agent Ollama — rejected due to VRAM constraints.

### D2: Model assignment per role
**Decision**: Emma and Morgan use Qwen3-Coder:32b (complex reasoning/planning). Sean uses Qwen3-Coder:8b (code generation/tool calling). GLM-4.7-Flash as fallback for any agent.
**Rationale**: Emma and Morgan need stronger reasoning for task decomposition and architecture. Sean needs fast, reliable code generation. The 32b model fits in 24 GB VRAM; the 8b model fits in 8 GB.

### D3: Docker networking — single internal network
**Decision**: All containers share one internal Docker network (`ai-team-net`). Only Portainer (9000) and Grafana (3000) are exposed to the host.
**Rationale**: Simplest networking model. Agents reach Ollama via internal DNS (`http://ollama:11434`). No agent gateway ports are exposed to the host, reducing attack surface.

### D4: Memory persistence — named Docker volumes per agent
**Decision**: Each agent gets its own named volume (`emma-memory`, `morgan-memory`, `sean-memory`). Memory files are Markdown. Agents cannot access each other's volumes.
**Rationale**: Named volumes persist across container restarts and context resets. Per-agent isolation ensures cross-agent knowledge flows only via Slack, preventing unintended information leakage.

### D5: Context window as a working day
**Decision**: When an agent's context approaches capacity, it executes an end-of-day routine: writes a structured summary to its memory volume, posts a handoff note to Slack, then resets context. On fresh context, it reads its memory file to reconstruct state.
**Rationale**: This pattern from the plan document provides graceful degradation when hitting context limits, with no data loss.

### D6: Slack channel structure — 6 dedicated channels
**Decision**: #po-commands, #pm-tasks, #architecture, #dev-updates, #general, #loop-alerts. Each has defined writers/readers per the plan.
**Rationale**: Separation of concerns. #po-commands is the audit trail for all PO directives. #loop-alerts isolates loop escalations from normal workflow.

### D7: Secrets management — Docker secrets + .env files
**Decision**: Slack tokens, Bitbucket app passwords, and Ollama config are passed via `.env` file for Docker Compose and Docker secrets for sensitive values. Never hardcoded in compose files.
**Rationale**: Standard Docker security practice. `.env` keeps compose files portable; Docker secrets provide an additional layer for production-sensitive values.

## Risks / Trade-offs

- **[VRAM contention]** Three agents hitting Ollama concurrently may queue requests and slow response times. → Mitigation: Ollama queues requests natively; monitor via Grafana and tune concurrency if needed. Consider smaller fallback models during peak load.

- **[Context window limits]** 64k tokens may not be sufficient for complex multi-step tasks. → Mitigation: End-of-day memory routine ensures graceful context resets. Tasks should be decomposed into small enough units.

- **[Slack rate limits]** High-frequency agent communication may hit Slack API rate limits. → Mitigation: Implement message batching or cooldown periods in agent system prompts. Monitor via Loki logs.

- **[Loop detection false positives]** Legitimate repeated messages (e.g., status updates) may trigger loop detection. → Mitigation: Loop detection uses 80% similarity threshold over 10-minute windows. Tune thresholds based on observed patterns.

- **[Single point of failure — Ollama]** If Ollama goes down, all agents stop. → Mitigation: Docker Compose restart policies (`unless-stopped`). Grafana alerting on Ollama health endpoint.

- **[Prompt injection via Slack]** Agents reading each other's messages could be manipulated. → Mitigation: System prompts instruct agents to treat all Slack content as untrusted. No instruction execution from peer messages without PO approval.
