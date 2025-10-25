#!/usr/bin/env bash
set -euo pipefail

# Docker Swarm Autoscaling Script
# This script monitors service metrics and scales replicas based on CPU/memory usage

SERVICE_NAME="${1:-student-prediction_backend}"
MIN_REPLICAS="${2:-2}"
MAX_REPLICAS="${3:-10}"
CPU_THRESHOLD="${4:-70}"  # Scale up if CPU > 70%
SCALE_UP_BY="${5:-2}"      # Add 2 replicas when scaling up
SCALE_DOWN_BY="${6:-1}"    # Remove 1 replica when scaling down
CHECK_INTERVAL="${7:-5}"  # Check every 30 seconds

echo "🔄 Starting autoscaler for service: $SERVICE_NAME"
echo "📊 Config: MIN=$MIN_REPLICAS, MAX=$MAX_REPLICAS, CPU_THRESHOLD=${CPU_THRESHOLD}%"
echo "⏱️  Check interval: ${CHECK_INTERVAL}s"
echo ""

while true; do
    # Get current replica count
    CURRENT_REPLICAS=$(docker service ls --filter "name=$SERVICE_NAME" --format "{{.Replicas}}" | cut -d'/' -f1)
    
    if [ -z "$CURRENT_REPLICAS" ]; then
        echo "⚠️  Service $SERVICE_NAME not found. Waiting..."
        sleep $CHECK_INTERVAL
        continue
    fi

    # Get service stats (this is a simplified example - you'd need proper monitoring)
    # In production, use Prometheus + Grafana or similar
    STATS=$(docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemPerc}}" | grep "$SERVICE_NAME" || true)
    
    if [ -z "$STATS" ]; then
        echo "⚠️  No stats available yet. Waiting..."
        sleep $CHECK_INTERVAL
        continue
    fi
    
    # Calculate average CPU usage across all replicas
    AVG_CPU=$(echo "$STATS" | awk '{sum += substr($2, 1, length($2)-1); count++} END {if (count > 0) print int(sum/count); else print 0}')
    
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] 📈 Service: $SERVICE_NAME | Replicas: $CURRENT_REPLICAS | Avg CPU: ${AVG_CPU}%"
    
    # Scale up if CPU exceeds threshold and not at max
    if [ "$AVG_CPU" -gt "$CPU_THRESHOLD" ] && [ "$CURRENT_REPLICAS" -lt "$MAX_REPLICAS" ]; then
        NEW_REPLICAS=$((CURRENT_REPLICAS + SCALE_UP_BY))
        if [ "$NEW_REPLICAS" -gt "$MAX_REPLICAS" ]; then
            NEW_REPLICAS=$MAX_REPLICAS
        fi
        echo "🚀 SCALING UP: $CURRENT_REPLICAS → $NEW_REPLICAS (CPU: ${AVG_CPU}% > ${CPU_THRESHOLD}%)"
        docker service scale "$SERVICE_NAME=$NEW_REPLICAS"
    
    # Scale down if CPU is low and above minimum
    elif [ "$AVG_CPU" -lt 30 ] && [ "$CURRENT_REPLICAS" -gt "$MIN_REPLICAS" ]; then
        NEW_REPLICAS=$((CURRENT_REPLICAS - SCALE_DOWN_BY))
        if [ "$NEW_REPLICAS" -lt "$MIN_REPLICAS" ]; then
            NEW_REPLICAS=$MIN_REPLICAS
        fi
        echo "📉 SCALING DOWN: $CURRENT_REPLICAS → $NEW_REPLICAS (CPU: ${AVG_CPU}% < 30%)"
        docker service scale "$SERVICE_NAME=$NEW_REPLICAS"
    else
        echo "✅ No scaling needed"
    fi
    
    echo ""
    sleep $CHECK_INTERVAL
done
