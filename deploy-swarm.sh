#!/usr/bin/env bash
set -euo pipefail

echo "🐳 Building Docker images for Swarm deployment..."

# Build backend image
echo "📦 Building backend image..."
docker build -t student-prediction-backend:latest ./backend

# Build frontend image
echo "📦 Building frontend image..."
docker build -t student-prediction-frontend:latest ./frontend

echo "✅ Images built successfully!"
echo ""
echo "🔧 Initializing Docker Swarm (if not already initialized)..."

# Check if swarm is active
if docker info 2>/dev/null | grep -q "Swarm: active"; then
    echo "ℹ️  Swarm already initialized and active"
else
    echo "🔄 Initializing new swarm..."
    # Leave any inactive swarm first
    docker swarm leave --force 2>/dev/null || true
    
    # Get the primary IPv4 address
    PRIMARY_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -1)
    
    if [ -z "$PRIMARY_IP" ]; then
        echo "⚠️  Could not detect IP address, using localhost..."
        PRIMARY_IP="127.0.0.1"
    fi
    
    echo "📡 Using IP address: $PRIMARY_IP"
    
    # Initialize new swarm with specific IP
    docker swarm init --advertise-addr "$PRIMARY_IP" 2>/dev/null || docker swarm init
    echo "✅ Swarm initialized"
fi

echo ""
echo "🚀 Deploying stack..."
docker stack deploy -c docker-stack.yml student-prediction

echo ""
echo "✅ Stack deployed! Waiting for services to start..."
sleep 5

echo ""
echo "📊 Service status:"
docker stack services student-prediction

echo ""
echo "📝 To view logs:"
echo "  docker service logs -f student-prediction_backend"
echo "  docker service logs -f student-prediction_frontend"
echo ""
echo "🔄 To enable autoscaling, run in a separate terminal:"
echo "  ./autoscale.sh student-prediction_backend 2 10 70"
echo "  ./autoscale.sh student-prediction_frontend 2 10 70"
echo ""
echo "🛑 To remove the stack:"
echo "  docker stack rm student-prediction"
