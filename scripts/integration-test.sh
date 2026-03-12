#!/bin/bash
# Integration test script for OpenClaw AI Team stack.
# Run after: docker compose up -d && ./scripts/pull-models.sh

set -euo pipefail

PASS=0
FAIL=0

check() {
  local desc="$1"
  shift
  if "$@" > /dev/null 2>&1; then
    echo "[PASS] $desc"
    ((PASS++))
  else
    echo "[FAIL] $desc"
    ((FAIL++))
  fi
}

echo "=== OpenClaw AI Team Integration Tests ==="
echo ""

# 9.1 - Stack health
echo "--- 9.1: Stack Health ---"
check "All containers running" docker compose ps --status running --format json
for svc in openclaw-emma openclaw-morgan openclaw-sean ollama portainer loki promtail grafana; do
  check "$svc is running" docker inspect --format='{{.State.Running}}' "$svc"
done

# 9.2 - Agent-to-Ollama communication
echo ""
echo "--- 9.2: Agent-to-Ollama Communication ---"
check "Ollama reachable from Emma" docker exec openclaw-emma curl -sf http://ollama:11434/api/tags
check "Ollama reachable from Morgan" docker exec openclaw-morgan curl -sf http://ollama:11434/api/tags
check "Ollama reachable from Sean" docker exec openclaw-sean curl -sf http://ollama:11434/api/tags

# 9.7 - Grafana + Loki
echo ""
echo "--- 9.7: Grafana & Loki ---"
check "Grafana accessible on port 3000" curl -sf http://localhost:3000/api/health
check "Loki data source configured in Grafana" curl -sf -u admin:admin http://localhost:3000/api/datasources

# Port exposure checks
echo ""
echo "--- Port Isolation ---"
check "Portainer accessible on port 9000" curl -sf http://localhost:9000
check "Agent ports NOT exposed (18789)" bash -c "! curl -sf http://localhost:18789 2>/dev/null"
check "Agent ports NOT exposed (18790)" bash -c "! curl -sf http://localhost:18790 2>/dev/null"
check "Agent ports NOT exposed (18791)" bash -c "! curl -sf http://localhost:18791 2>/dev/null"

# Memory volume checks
echo ""
echo "--- Memory Volumes ---"
check "Emma memory volume mounted" docker exec openclaw-emma test -d /app/memory
check "Morgan memory volume mounted" docker exec openclaw-morgan test -d /app/memory
check "Sean memory volume mounted" docker exec openclaw-sean test -d /app/memory

# No Docker socket in agents
echo ""
echo "--- Security: No Docker Socket ---"
check "Emma has no docker socket" bash -c "! docker exec openclaw-emma test -S /var/run/docker.sock"
check "Morgan has no docker socket" bash -c "! docker exec openclaw-morgan test -S /var/run/docker.sock"
check "Sean has no docker socket" bash -c "! docker exec openclaw-sean test -S /var/run/docker.sock"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
echo ""
echo "Manual tests remaining:"
echo "  9.3 - Test Slack message flow (requires Slack tokens configured)"
echo "  9.4 - Test PR workflow (requires Bitbucket accounts configured)"
echo "  9.5 - Test PO control commands (requires live Slack)"
echo "  9.6 - Test loop detection (requires simulated loop scenario)"
echo "  9.8 - Test context window memory persistence (requires agent interaction)"
