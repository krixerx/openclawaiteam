## ADDED Requirements

### Requirement: STOP ALL command
The Product Owner SHALL be able to post "STOP ALL" in #po-commands to immediately halt all running tasks across all agents.

#### Scenario: STOP ALL halts all agents
- **WHEN** the PO posts "STOP ALL" in #po-commands
- **THEN** Emma, Morgan, and Sean all immediately halt their current tasks and acknowledge the stop

### Requirement: STOP single agent command
The Product Owner SHALL be able to post "STOP @agent-name" to halt a specific agent's current task while other agents continue.

#### Scenario: STOP single agent
- **WHEN** the PO posts "STOP @emma" in #po-commands
- **THEN** Emma halts her current task immediately, while Morgan and Sean continue their work

### Requirement: PAUSE command
The Product Owner SHALL be able to post "PAUSE @agent-name" to pause a specific agent. The paused agent SHALL retain its current work state and await further instructions without abandoning its task.

#### Scenario: PAUSE preserves agent state
- **WHEN** the PO posts "PAUSE @sean" in #po-commands
- **THEN** Sean pauses mid-task, retains his work state, and awaits further instructions

### Requirement: RESUME command
The Product Owner SHALL be able to post "RESUME @agent-name" to resume a paused agent from where it left off.

#### Scenario: RESUME continues paused work
- **WHEN** the PO posts "RESUME @sean" in #po-commands after a PAUSE
- **THEN** Sean resumes his previous task from the point where he was paused

### Requirement: OVERRIDE command
The Product Owner SHALL be able to post "OVERRIDE: [new instruction]" to replace the current task of the active agent with a new instruction. The agent MUST acknowledge the override and pivot to the new instruction.

#### Scenario: OVERRIDE replaces current task
- **WHEN** the PO posts "OVERRIDE: Switch to fixing the login bug instead" in #po-commands
- **THEN** the active agent acknowledges the override, abandons its current task, and begins the new instruction

### Requirement: STATUS command
The Product Owner SHALL be able to post "STATUS" in #po-commands to request all agents to post a brief current-status summary.

#### Scenario: STATUS triggers status reports from all agents
- **WHEN** the PO posts "STATUS" in #po-commands
- **THEN** Emma, Morgan, and Sean each post a brief status summary to #po-commands within 30 seconds

### Requirement: PO command audit logging
All PO commands and agent acknowledgements MUST be logged in #po-commands for audit purposes. Commands received in other channels SHALL be routed to #po-commands.

#### Scenario: Commands logged for audit
- **WHEN** the PO issues any command
- **THEN** the command and all agent responses are recorded in #po-commands as an audit trail

### Requirement: PO supreme authority
No agent SHALL override, ignore, or delay a PO command. PO commands take immediate precedence over any in-progress task or inter-agent communication.

#### Scenario: PO command interrupts agent work
- **WHEN** Sean is mid-implementation and the PO posts "STOP @sean"
- **THEN** Sean stops immediately, even if code is partially written, and acknowledges the command
