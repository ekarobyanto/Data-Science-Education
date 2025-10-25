#!/usr/bin/env bash
set -euo pipefail

# Quick Autoscaling Demo Script
# This script demonstrates autoscaling by running a load test

echo "🎯 Student Prediction API - Autoscaling Demo"
echo "=============================================="
echo ""

# Check if swarm is initialized and active
if ! docker info 2>/dev/null | grep -q "Swarm: active"; then
    echo "⚠️  Docker Swarm is not active. Deploying stack first..."
    
    # Clean up any inactive swarm state
    echo "🧹 Cleaning up any previous swarm state..."
    docker swarm leave --force 2>/dev/null || true
    
    # Deploy
    ./deploy-swarm.sh
    
    echo ""
    echo "⏳ Waiting 30 seconds for services to be ready..."
    sleep 30
else
    echo "✅ Docker Swarm is already active"
    
    # Check if stack exists
    if ! docker stack ls | grep -q "student-prediction"; then
        echo "⚠️  Stack not deployed. Deploying now..."
        ./deploy-swarm.sh
        echo ""
        echo "⏳ Waiting 30 seconds for services to be ready..."
        sleep 30
    fi
fi

# Check if autoscaler is already running
if pgrep -f "autoscale.sh.*backend" >/dev/null; then
    echo "✅ Backend autoscaler is already running"
else
    echo "🔄 Starting backend autoscaler in background..."
    nohup ./autoscale.sh student-prediction_backend 2 10 70 > loadtests/results/autoscale-backend.log 2>&1 &
    BACKEND_PID=$!
    echo "   PID: $BACKEND_PID"
fi

if pgrep -f "autoscale.sh.*frontend" >/dev/null; then
    echo "✅ Frontend autoscaler is already running"
else
    echo "🔄 Starting frontend autoscaler in background..."
    nohup ./autoscale.sh student-prediction_frontend 2 10 70 > loadtests/results/autoscale-frontend.log 2>&1 &
    FRONTEND_PID=$!
    echo "   PID: $FRONTEND_PID"
fi

echo ""
echo "📊 Current service status:"
docker service ls | grep student-prediction

echo ""
echo "🚀 Running load test to trigger autoscaling..."
echo "   Test config: 1000 VUs for 60 seconds"
echo ""

# Run the load test
BASE_URL=http://localhost:5000 make loadtest K6_VUS=1000 K6_DURATION=60s

echo ""
echo "📈 Final service status after load test:"
docker service ls | grep student-prediction

echo ""
echo "📊 View autoscaler logs:"
echo "   Backend:  tail -f loadtests/results/autoscale-backend.log"
echo "   Frontend: tail -f loadtests/results/autoscale-frontend.log"
echo ""
echo "🛑 To stop autoscalers:"
echo "   pkill -f autoscale.sh"
echo ""
echo "✅ Demo complete!"
