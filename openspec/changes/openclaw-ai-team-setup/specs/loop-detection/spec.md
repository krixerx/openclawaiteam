## ADDED Requirements

### Requirement: Loop trigger detection
The system SHALL detect loops when any of the following conditions occur:
1. The same Slack message content (>= 80% similarity) appears 3 or more times within a 10-minute window involving the same agents
2. An agent posts to another agent's channel with no acknowledgement for 2 consecutive rounds
3. A task cycles between agents (e.g., Emma -> Morgan -> Sean -> Emma -> Morgan) more than 2 full cycles without a commit, design doc, or PO update
4. An agent calls another agent with a tool or message identical to a previous call in the same task session
5. A task remains in "in-progress" state for more than 30 minutes without measurable output

#### Scenario: Repeated message triggers loop detection
- **WHEN** Morgan posts a message with >= 80% similarity to a previous message 3 times within 10 minutes to the same channel
- **THEN** the system raises LOOP_DETECTED and initiates the circuit-breaker sequence

#### Scenario: Unacknowledged messages trigger loop detection
- **WHEN** Emma posts to Morgan's channel and receives no acknowledgement for 2 consecutive rounds
- **THEN** the system raises LOOP_DETECTED

#### Scenario: Task cycle triggers loop detection
- **WHEN** a task cycles between Emma, Morgan, and Sean more than 2 complete cycles without producing a commit, design doc, or PO update
- **THEN** the system raises LOOP_DETECTED

#### Scenario: Stalled task triggers loop detection
- **WHEN** a task remains "in-progress" for more than 30 minutes without any measurable output
- **THEN** the system raises LOOP_DETECTED

### Requirement: Circuit-breaker immediate stop
When a loop is detected, ALL involved agents MUST stop immediately. No agent may continue the looped activity. This rule MUST NOT be overridable by any agent.

#### Scenario: All involved agents stop on loop detection
- **WHEN** LOOP_DETECTED is raised involving Emma and Morgan
- **THEN** both Emma and Morgan pause their current tasks immediately

### Requirement: Loop alert posting
The detecting agent SHALL post a structured loop alert to #loop-alerts containing: task ID/description, agents involved, loop type (repeated message, task cycle, timeout, identical tool call), and iteration count.

#### Scenario: Structured alert posted to #loop-alerts
- **WHEN** Emma detects a loop
- **THEN** Emma posts to #loop-alerts with format: LOOP DETECTED, Task, Agents involved, Loop type, Iteration count, and a note that agents have been paused

### Requirement: Agent loop explanation
Each agent involved in a detected loop SHALL independently post its own explanation to #loop-alerts. The explanation MUST include: task being worked on, what the agent was trying to achieve, why it kept responding, what it believes caused the loop, and an optional resolution suggestion. Agents MUST NOT coordinate their explanations before posting.

#### Scenario: Each agent posts independent explanation
- **WHEN** a loop is detected involving Emma and Morgan
- **THEN** both Emma and Morgan independently post their explanations to #loop-alerts using the structured LOOP EXPLANATION format

### Requirement: PO decision required to resume
No agent involved in a loop MAY resume work until the Product Owner issues a decision. Valid PO decisions are: LOOP APPROVED, OVERRIDE with new instruction, STOP ALL, or a targeted instruction to one agent.

#### Scenario: Agents wait for PO decision
- **WHEN** a loop is detected and all agents have posted explanations
- **THEN** all involved agents remain paused until the PO posts a decision in #loop-alerts or #po-commands

#### Scenario: PO approves loop continuation
- **WHEN** the PO posts "LOOP APPROVED" after reviewing explanations
- **THEN** the involved agents resume their previous activity for one additional iteration

### Requirement: Loop resolution logging
When a loop is resolved, each involved agent SHALL log the resolution (PO decision and outcome) in its memory file for future reference.

#### Scenario: Loop resolution saved to memory
- **WHEN** the PO resolves a loop with an OVERRIDE instruction
- **THEN** each involved agent records the loop event, PO decision, and new instruction in its memory file
