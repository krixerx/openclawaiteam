## ADDED Requirements

### Requirement: Loki log aggregation
The system SHALL run a Grafana Loki instance that collects logs from all agent containers, the Ollama service, and supporting services. Logs SHALL be tagged with the source container name.

#### Scenario: Agent logs collected by Loki
- **WHEN** Emma's container writes log output
- **THEN** the log entry is collected by Loki and tagged with the source label `openclaw-emma`

#### Scenario: Ollama logs collected by Loki
- **WHEN** Ollama processes a request and logs the activity
- **THEN** the log entry is collected by Loki and tagged with the source label `ollama`

### Requirement: Grafana dashboard for monitoring
The system SHALL provide pre-configured Grafana dashboards that display: agent activity logs, Ollama request metrics (latency, model usage), container health status, and loop detection events.

#### Scenario: Operator views agent activity
- **WHEN** the operator opens the Grafana dashboard at `http://localhost:3000`
- **THEN** the dashboard shows recent log entries from all agents, filterable by agent name

#### Scenario: Operator monitors Ollama performance
- **WHEN** the operator views the Ollama metrics panel
- **THEN** the dashboard shows request counts, latency, and which models are being used

### Requirement: Loki as Grafana data source
Loki SHALL be pre-configured as a data source in Grafana. The connection SHALL use the internal Docker network address `http://loki:3100`.

#### Scenario: Grafana connects to Loki on startup
- **WHEN** the Grafana container starts
- **THEN** Loki is automatically available as a data source without manual configuration

### Requirement: Log retention policy
Loki SHALL retain logs for a minimum of 7 days. Logs older than 30 days MAY be automatically purged.

#### Scenario: Recent logs are available
- **WHEN** the operator queries Loki for logs from 5 days ago
- **THEN** the logs are available and searchable

### Requirement: Loop event logging
All loop detection events, agent explanations, and PO decisions SHALL be logged in Loki with a dedicated label (e.g., `event_type=loop_detection`) for easy filtering and weekly review.

#### Scenario: Loop events filterable in Grafana
- **WHEN** the operator filters Grafana logs by `event_type=loop_detection`
- **THEN** all loop detection events, explanations, and resolutions are displayed chronologically
