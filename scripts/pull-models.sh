#!/bin/bash
# Pull all required models into the shared Ollama instance.
# Run after the Ollama container is up: docker compose up -d ollama && ./scripts/pull-models.sh

set -euo pipefail

OLLAMA_CONTAINER="ollama"

echo "Pulling models into Ollama..."

echo "[1/3] Pulling qwen3-coder:32b (Emma & Morgan - planning/architecture)..."
docker exec "$OLLAMA_CONTAINER" ollama pull qwen3-coder:32b

echo "[2/3] Pulling qwen3-coder:8b (Sean - code generation/QA)..."
docker exec "$OLLAMA_CONTAINER" ollama pull qwen3-coder:8b

echo "[3/3] Pulling glm-4.7-flash (all agents - fallback)..."
docker exec "$OLLAMA_CONTAINER" ollama pull glm-4.7-flash

echo "All models pulled successfully."
docker exec "$OLLAMA_CONTAINER" ollama list
