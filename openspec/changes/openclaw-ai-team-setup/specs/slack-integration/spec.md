## ADDED Requirements

### Requirement: Slack bot creation for each agent
The system SHALL have three Slack bots: `emma-bot`, `morgan-bot`, and `sean-bot`. Each bot SHALL be configured with appropriate OAuth scopes to read and write messages in their designated channels.

#### Scenario: Emma bot posts to #pm-tasks
- **WHEN** Emma needs to assign a task
- **THEN** emma-bot posts the assignment message to the #pm-tasks channel

#### Scenario: Sean bot posts to #dev-updates
- **WHEN** Sean completes a PR or test run
- **THEN** sean-bot posts the results to the #dev-updates channel

### Requirement: Channel structure with defined access patterns
The system SHALL create 6 Slack channels with the following write/read permissions:
- `#po-commands`: PO writes; Emma and all agents read
- `#pm-tasks`: Emma writes; Morgan, Sean, and PO read
- `#architecture`: Morgan writes; Emma, Sean, and PO read
- `#dev-updates`: Sean writes; Emma, Morgan, and PO read
- `#general`: All agents write; all read
- `#loop-alerts`: Any agent writes (automated); PO reads

#### Scenario: PO posts task to #po-commands
- **WHEN** the Product Owner posts "Emma, build user auth module" to #po-commands
- **THEN** Emma receives and processes the task instruction

#### Scenario: Morgan posts design to #architecture
- **WHEN** Morgan completes an architecture design
- **THEN** morgan-bot posts the design document to #architecture, visible to Emma, Sean, and PO

### Requirement: Message routing for PO commands
All PO commands MUST be posted in #po-commands. If a PO command is sent to another channel, the system SHALL acknowledge it but route it to #po-commands for audit logging.

#### Scenario: PO command in wrong channel gets routed
- **WHEN** the PO posts "STOP @emma" in #general instead of #po-commands
- **THEN** the command is acknowledged in #general and a copy is posted to #po-commands for audit

### Requirement: Slack token configuration via environment
Slack bot tokens SHALL be configured via environment variables in the `.env` file. Tokens MUST NOT be hardcoded in any configuration file or committed to the repository.

#### Scenario: Slack tokens loaded from environment
- **WHEN** the Docker Compose stack starts
- **THEN** each agent container receives its Slack bot token from the environment variable defined in `.env`
