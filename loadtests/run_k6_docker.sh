#!/usr/bin/env bash
set -euo pipefail

# Helper to run k6 via docker-compose. Run from repository root:
#   ./loadtests/run_k6_docker.sh

COMPOSE_CMD="docker compose"
if ! command -v docker >/dev/null 2>&1 || ! $COMPOSE_CMD version >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
fi

echo "Starting k6 against backend using docker compose files..."
# Use the repo root docker-compose and the loadtests docker-compose override
$COMPOSE_CMD -f docker-compose.yml -f loadtests/docker-compose.k6.yml up --abort-on-container-exit --exit-code-from k6 --build
