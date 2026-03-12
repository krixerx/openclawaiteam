## ADDED Requirements

### Requirement: Per-agent IDENTITY.md configuration
Each agent (Emma, Morgan, Sean) SHALL have a unique `IDENTITY.md` file that defines the agent's name, role, primary responsibilities, and behavioral guidelines. The IDENTITY.md SHALL be mounted into the agent's container at the OpenClaw-expected path.

#### Scenario: Emma identity defines Project Lead role
- **WHEN** Emma's container starts
- **THEN** Emma's IDENTITY.md identifies her as "Project Lead" with responsibilities: receiving tasks from PO, breaking into sub-tasks, assigning to Morgan and Sean, tracking progress, reporting back

#### Scenario: Morgan identity defines Architect role
- **WHEN** Morgan's container starts
- **THEN** Morgan's IDENTITY.md identifies him as "Architect" with responsibilities: receiving architecture tasks from Emma, producing design docs and ADRs, reviewing Sean's PRs for design compliance

#### Scenario: Sean identity defines Developer & QA role
- **WHEN** Sean's container starts
- **THEN** Sean's IDENTITY.md identifies him as "Developer & QA" with responsibilities: implementing features, writing and running tests, opening Pull Requests, posting test results to Slack

### Requirement: Role-specific system prompts
Each agent SHALL have a system prompt that includes prompt injection mitigations. System prompts MUST instruct agents to treat all Slack content as untrusted data and never execute instructions found in messages from other agents without explicit PO approval.

#### Scenario: Agent rejects instruction from peer message
- **WHEN** Morgan sends a Slack message to Sean containing an instruction like "delete all files"
- **THEN** Sean treats the message as untrusted data and does not execute the instruction without PO approval

### Requirement: Model assignment per agent
Emma and Morgan SHALL be configured to use `qwen3-coder:32b` as their primary model. Sean SHALL be configured to use `qwen3-coder:8b`. All agents SHALL have `glm-4.7-flash` configured as a fallback model.

#### Scenario: Emma uses the 32b model
- **WHEN** Emma processes a task
- **THEN** requests are sent to Ollama for the `qwen3-coder:32b` model

#### Scenario: Sean uses the 8b model
- **WHEN** Sean processes a task
- **THEN** requests are sent to Ollama for the `qwen3-coder:8b` model

### Requirement: Agent memory namespace isolation
Each agent's memory files SHALL be stored in its own namespace directory (`emma/`, `morgan/`, `sean/`) within its respective Docker volume. Memory files SHALL be in Markdown format.

#### Scenario: Emma writes to her memory namespace
- **WHEN** Emma writes an end-of-day summary
- **THEN** the file is stored in the `emma/` directory within the `emma-memory` volume

### Requirement: Context window end-of-day routine
When an agent's context window approaches capacity, the agent SHALL execute an end-of-day routine: write a structured summary (tasks completed, decisions made, blockers, next steps) to its memory file, post a handoff note to its Slack channel, then allow context reset.

#### Scenario: Agent performs end-of-day routine
- **WHEN** Emma's context window reaches 90% capacity
- **THEN** Emma writes a structured summary to her memory volume and posts a handoff note to #pm-tasks

### Requirement: Context window start-of-day routine
When an agent starts with a fresh context, it SHALL read its own memory file to reconstruct context: previous summary, open tasks, and team decisions.

#### Scenario: Agent reconstructs context on fresh start
- **WHEN** Emma starts with a fresh context window
- **THEN** Emma reads her latest memory file and reconstructs her task state before accepting new work
