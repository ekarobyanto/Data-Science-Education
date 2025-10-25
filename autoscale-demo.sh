#!/usr/bin/env bash
set -euo pipefail

# Demo Autoscaler with LOW threshold for testing
# This makes it easy to see autoscaling in action

SERVICE_NAME="${1:-student-prediction_backend}"
MIN_REPLICAS="${2:-2}"
MAX_REPLICAS="${3:-6}"
CPU_THRESHOLD="${4:-5}"  # Very low threshold for demo (5%)

echo "🎯 DEMO Autoscaler (Low Threshold for Testing)"
echo "🔄 Starting autoscaler for service: $SERVICE_NAME"
echo "📊 Config: MIN=$MIN_REPLICAS, MAX=$MAX_REPLICAS, CPU_THRESHOLD=${CPU_THRESHOLD}%"
echo "⏱️  Check interval: 5s"
echo ""
echo "💡 TIP: This uses a LOW CPU threshold ($CPU_THRESHOLD%) so you can easily see scaling"
echo ""

while true; do
    CURRENT_REPLICAS=$(docker service ls --filter "name=$SERVICE_NAME" --format "{{.Replicas}}" | cut -d'/' -f1)
    
    if [ -z "$CURRENT_REPLICAS" ]; then
        echo "⚠️  Service $SERVICE_NAME not found. Waiting..."
        sleep 5
        continue
    fi

    STATS=$(docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemPerc}}" | grep "$SERVICE_NAME" || true)
    
    if [ -z "$STATS" ]; then
        echo "⚠️  No stats available yet. Waiting..."
        sleep 5
        continue
    fi
    
    AVG_CPU=$(echo "$STATS" | awk '{sum += substr($2, 1, length($2)-1); count++} END {if (count > 0) print int(sum/count); else print 0}')
    
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] 📈 Replicas: $CURRENT_REPLICAS | Avg CPU: ${AVG_CPU}%"
    
    # Scale up if CPU exceeds threshold
    if [ "$AVG_CPU" -gt "$CPU_THRESHOLD" ] && [ "$CURRENT_REPLICAS" -lt "$MAX_REPLICAS" ]; then
        NEW_REPLICAS=$((CURRENT_REPLICAS + 2))
        if [ "$NEW_REPLICAS" -gt "$MAX_REPLICAS" ]; then
            NEW_REPLICAS=$MAX_REPLICAS
        fi
        echo "🚀 SCALING UP: $CURRENT_REPLICAS → $NEW_REPLICAS (CPU: ${AVG_CPU}% > ${CPU_THRESHOLD}%)"
        docker service scale "$SERVICE_NAME=$NEW_REPLICAS"
    
    # Scale down if CPU is very low
    elif [ "$AVG_CPU" -lt 2 ] && [ "$CURRENT_REPLICAS" -gt "$MIN_REPLICAS" ]; then
        NEW_REPLICAS=$((CURRENT_REPLICAS - 1))
        if [ "$NEW_REPLICAS" -lt "$MIN_REPLICAS" ]; then
            NEW_REPLICAS=$MIN_REPLICAS
        fi
        echo "📉 SCALING DOWN: $CURRENT_REPLICAS → $NEW_REPLICAS (CPU: ${AVG_CPU}% < 2%)"
        docker service scale "$SERVICE_NAME=$NEW_REPLICAS"
    else
        echo "✅ No scaling needed"
    fi
    
    echo ""
    sleep 5
done
