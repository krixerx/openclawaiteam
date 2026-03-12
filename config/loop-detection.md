# Loop Detection & Circuit Breaker Rules

## Loop Triggers

A loop is declared when ANY ONE of these conditions is met:

1. **Repeated Message**: The same Slack message content (>= 80% similarity) appears 3+ times within a 10-minute window involving the same agents
2. **Unacknowledged Messages**: An agent posts to another agent's channel with no Slack reaction or acknowledgement for 2 consecutive rounds
3. **Task Cycle**: A task moves between agents (e.g., Emma -> Morgan -> Sean -> Emma -> Morgan) more than 2 full cycles without a commit, design doc, or PO update
4. **Identical Tool Call**: An agent calls another agent with a tool or message identical to a previous call in the same task session
5. **Stalled Task**: A task remains "in-progress" for more than 30 minutes without measurable output (commit, file, message)

## Circuit Breaker Sequence

When a loop is detected, ALL involved agents MUST follow this exact sequence:

### Step 1: Detect
Any agent that identifies a loop condition raises LOOP_DETECTED internally.

### Step 2: Stop
ALL agents involved in the loop pause their current task immediately. This is non-negotiable — no agent may continue.

### Step 3: Alert
The detecting agent posts the structured loop alert to #loop-alerts:

```
LOOP DETECTED
Task: [task-id / description]
Agents involved: [e.g. Emma, Morgan]
Loop type: [repeated message | task cycle | timeout | identical tool call]
Iteration count: [N]
All involved agents have been paused and will now post their individual explanations below.
Awaiting PO decision after reviewing all explanations.
```

### Step 4: Explain
Each involved agent independently posts its own explanation to #loop-alerts:

```
LOOP EXPLANATION — [Agent Name]
Task I was working on: [task-id / description]
What I was trying to achieve: [agent's goal at the time]
Why I kept responding: [honest reasoning]
What I believe caused the loop: [root cause from my perspective]
What I suggest to resolve it: [optional recommendation]
I am now paused and awaiting your decision.
```

Agents MUST NOT coordinate their explanations with each other before posting.

### Step 5: Wait
All involved agents remain paused until the PO issues a decision.

### Step 6: PO Decision
Valid PO decisions:
- `LOOP APPROVED` — Continue as-is for one additional iteration
- `OVERRIDE: [new instruction]` — Redirect with new instructions
- `STOP ALL` — Terminate the task
- Targeted instruction to one specific agent

### Step 7: Resume & Log
Agents act on the PO decision and log the resolution in their memory files:
- Loop event details
- PO decision
- Outcome and new direction
