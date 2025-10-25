#!/usr/bin/env bash
set -euo pipefail

echo "🧹 Cleaning up Docker Swarm and related resources..."
echo ""

# Stop autoscalers if running
if pgrep -f "autoscale.sh" >/dev/null; then
    echo "🛑 Stopping autoscalers..."
    pkill -f "autoscale.sh" || true
    echo "✅ Autoscalers stopped"
fi

# Remove stack if exists
if docker stack ls 2>/dev/null | grep -q "student-prediction"; then
    echo "🗑️  Removing student-prediction stack..."
    docker stack rm student-prediction
    echo "⏳ Waiting for stack removal..."
    sleep 10
    echo "✅ Stack removed"
else
    echo "ℹ️  No stack to remove"
fi

# Leave swarm
if docker info 2>/dev/null | grep -q "Swarm: active"; then
    echo "🚪 Leaving swarm..."
    docker swarm leave --force
    echo "✅ Left swarm"
else
    echo "ℹ️  Not in swarm mode"
fi

# Clean up any orphaned containers
echo "🧹 Cleaning up containers..."
docker ps -a --filter "name=student-prediction" -q | xargs -r docker rm -f 2>/dev/null || true

# Clean up networks
echo "🧹 Cleaning up networks..."
docker network ls --filter "name=student-prediction" -q | xargs -r docker network rm 2>/dev/null || true

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "📌 Next steps:"
echo "   - To start fresh: ./deploy-swarm.sh"
echo "   - To use regular compose: docker compose up -d"
