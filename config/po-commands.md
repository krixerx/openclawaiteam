# Product Owner Command Handlers

All PO commands MUST be processed from #po-commands. The Product Owner has supreme authority — no agent may override, ignore, or delay a PO command.

## Command Reference

### STOP ALL
- **Trigger**: PO posts `STOP ALL` in #po-commands
- **Effect**: ALL agents immediately halt their current tasks
- **Agent action**: Stop current work, acknowledge with "Stopped. Awaiting instructions." in #po-commands
- **Scope**: Global — all agents

### STOP @agent-name
- **Trigger**: PO posts `STOP @emma`, `STOP @morgan`, or `STOP @sean`
- **Effect**: Named agent halts; other agents continue
- **Agent action**: Named agent stops and acknowledges; other agents ignore
- **Scope**: Single agent

### PAUSE @agent-name
- **Trigger**: PO posts `PAUSE @emma`, `PAUSE @morgan`, or `PAUSE @sean`
- **Effect**: Named agent pauses mid-task, retains work state
- **Agent action**: Save current state to memory, acknowledge with "Paused. Work state saved. Awaiting instructions."
- **Scope**: Single agent

### RESUME @agent-name
- **Trigger**: PO posts `RESUME @emma`, `RESUME @morgan`, or `RESUME @sean`
- **Effect**: Named agent resumes from saved state
- **Agent action**: Read saved state from memory, resume task, acknowledge with "Resumed from saved state."
- **Scope**: Single agent

### OVERRIDE: [new instruction]
- **Trigger**: PO posts `OVERRIDE: <instruction>`
- **Effect**: Active agent replaces current task with new instruction
- **Agent action**: Acknowledge override, abandon current task, begin new instruction
- **Scope**: Active agent(s)

### STATUS
- **Trigger**: PO posts `STATUS`
- **Effect**: All agents post current status summaries
- **Agent action**: Post brief summary to #po-commands: current task, progress, blockers
- **Scope**: Global — all agents respond

## Audit Logging

All commands and responses are recorded in #po-commands as a permanent audit trail. Each agent acknowledgement includes:
- Timestamp
- Agent name
- Command received
- Action taken
