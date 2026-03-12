## ADDED Requirements

### Requirement: Docker Compose stack definition
The system SHALL provide a `docker-compose.yml` file that defines all services: openclaw-emma, openclaw-morgan, openclaw-sean, ollama, portainer, loki, and grafana. Each service SHALL use the images specified in the architecture plan (openclaw/openclaw:latest for agents, ollama/ollama:latest, portainer/portainer-ce, grafana/loki:latest, grafana/grafana:latest).

#### Scenario: Stack starts successfully
- **WHEN** the operator runs `docker compose up -d`
- **THEN** all 7 services start and reach healthy status within 120 seconds

#### Scenario: Stack stops cleanly
- **WHEN** the operator runs `docker compose down`
- **THEN** all containers stop and are removed, but named volumes persist

### Requirement: Internal Docker network isolation
The system SHALL create a single internal Docker network named `ai-team-net`. All agent containers, Ollama, Loki, and Grafana MUST be attached to this network. No container SHALL use host networking mode.

#### Scenario: Agents communicate with Ollama over internal network
- **WHEN** an agent container sends a request to `http://ollama:11434`
- **THEN** the request reaches the Ollama service via the internal Docker network

#### Scenario: Agent gateway ports are not exposed to host
- **WHEN** the stack is running
- **THEN** ports 18789, 18790, 18791 (agent gateways) are NOT bound to the host interface

### Requirement: Host-exposed services limited to Portainer and Grafana
Only Portainer (port 9000) and Grafana (port 3000) SHALL be exposed to the host machine. All other service ports MUST remain internal to the Docker network.

#### Scenario: Portainer accessible from host
- **WHEN** the operator navigates to `http://localhost:9000`
- **THEN** the Portainer UI loads successfully

#### Scenario: Grafana accessible from host
- **WHEN** the operator navigates to `http://localhost:3000`
- **THEN** the Grafana UI loads successfully

### Requirement: Named volumes for agent memory persistence
The system SHALL create named Docker volumes `emma-memory`, `morgan-memory`, and `sean-memory`. Each agent container MUST mount only its own memory volume. Volumes MUST persist across container restarts and `docker compose down`.

#### Scenario: Memory persists after container restart
- **WHEN** the operator restarts an agent container
- **THEN** the agent's memory files from before the restart are still present in its volume

#### Scenario: Agents cannot access each other's volumes
- **WHEN** the Emma container attempts to read files from the Morgan memory volume
- **THEN** the operation fails because the volume is not mounted in Emma's container

### Requirement: No Docker socket mounting
No agent container SHALL have `/var/run/docker.sock` mounted. Agents MUST NOT have the ability to spawn, stop, or inspect other Docker containers.

#### Scenario: Agent cannot access Docker API
- **WHEN** an agent attempts to call the Docker socket
- **THEN** the call fails because the socket is not available inside the container

### Requirement: Container restart policy
All service containers SHALL use the `unless-stopped` restart policy to ensure automatic recovery after crashes or host reboots.

#### Scenario: Container recovers after crash
- **WHEN** an agent container process crashes unexpectedly
- **THEN** Docker automatically restarts the container

### Requirement: Environment file for configuration
The system SHALL use a `.env` file for Docker Compose variable substitution. Slack tokens, Bitbucket app passwords, and model configuration MUST be defined in the `.env` file, not hardcoded in `docker-compose.yml`. A `.env.example` template SHALL be provided.

#### Scenario: Operator configures secrets via .env
- **WHEN** the operator copies `.env.example` to `.env` and fills in credentials
- **THEN** `docker compose up` uses those values for service configuration
