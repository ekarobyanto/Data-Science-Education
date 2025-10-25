# Docker Swarm Autoscaling Setup

This guide explains how to set up autoscaling for the Student Prediction API using Docker Swarm.

## Why Docker Swarm?

Docker Compose doesn't support autoscaling. For container autoscaling, you need:
- **Docker Swarm** (simpler, built into Docker)
- **Kubernetes** (more complex, requires separate cluster)

This setup uses Docker Swarm for simplicity.

## Architecture with Autoscaling

```
🌐 Host Machine (localhost:5000, localhost:3000)
    ↓
📦 Nginx Load Balancer
    ↓
├─→ 🔧 Backend: 2-10 replicas (autoscaled based on CPU)
│   └─ Each: 1 CPU max, 1GB RAM max
│
└─→ 🎨 Frontend: 2-10 replicas (autoscaled based on CPU)
    └─ Each: 1 CPU max, 1GB RAM max
```

## Quick Start

### 1. Deploy with Autoscaling

```bash
# Build images and deploy to Swarm
./deploy-swarm.sh
```

### 2. Start Autoscaler (in separate terminals)

```bash
# Terminal 1: Autoscale backend
./autoscale.sh student-prediction_backend 2 10 70

# Terminal 2: Autoscale frontend
./autoscale.sh student-prediction_frontend 2 10 70
```

**Autoscaler Parameters:**
- Service name
- Min replicas (default: 2)
- Max replicas (default: 10)
- CPU threshold % (default: 70)
- Scale up by (default: 2)
- Scale down by (default: 1)
- Check interval in seconds (default: 30)

### 3. Run Load Tests

```bash
# This will trigger autoscaling
make loadtest K6_VUS=1000 K6_DURATION=60s
```

### 4. Monitor Scaling

```bash
# Watch service replicas
watch docker service ls

# View specific service
docker service ps student-prediction_backend --no-trunc

# View logs
docker service logs -f student-prediction_backend
```

### 5. Manual Scaling (optional)

```bash
# Scale to specific number
docker service scale student-prediction_backend=5

# Scale multiple services
docker service scale student-prediction_backend=5 student-prediction_frontend=3
```

## Autoscaling Behavior

### Scale Up Triggers
- **Condition**: Average CPU > 70% across all replicas
- **Action**: Add 2 replicas (up to max of 10)
- **Example**: 2 replicas at 80% CPU → scales to 4 replicas

### Scale Down Triggers
- **Condition**: Average CPU < 30% across all replicas
- **Action**: Remove 1 replica (down to min of 2)
- **Example**: 5 replicas at 20% CPU → scales to 4 replicas

### Resource Limits
- Each replica limited to 1 CPU and 1GB RAM
- With 10 replicas max: 10 CPUs + 10GB RAM max per service
- Total system max: 20 CPUs + 20GB RAM (backend + frontend)

## Configuration Files

- `docker-stack.yml` - Swarm stack definition with resource limits
- `autoscale.sh` - Autoscaling script that monitors and scales
- `deploy-swarm.sh` - Deployment helper script
- `nginx.conf` - Load balancer configuration (unchanged)

## Monitoring & Debugging

```bash
# Stack overview
docker stack ps student-prediction

# Service details
docker service inspect student-prediction_backend

# Container stats
docker stats

# Remove stack
docker stack rm student-prediction

# Leave swarm mode (cleanup)
docker swarm leave --force
```

## Production Considerations

For production environments, consider:

1. **Better Monitoring**: Use Prometheus + Grafana for metrics
2. **Advanced Autoscaling**: Use tools like Docker Flow or migrate to Kubernetes with HPA
3. **Multiple Metrics**: Scale based on CPU, memory, and request rate
4. **Health Checks**: Ensure proper health checks before scaling decisions
5. **Gradual Scaling**: Implement cooldown periods between scale operations

## Switching Back to Docker Compose

To go back to regular Docker Compose:

```bash
# Stop swarm stack
docker stack rm student-prediction

# Leave swarm mode
docker swarm leave --force

# Use regular compose
docker compose up -d
```

## Advanced: Kubernetes Alternative

For larger deployments, consider Kubernetes with Horizontal Pod Autoscaler (HPA):

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

This provides more sophisticated autoscaling but requires a Kubernetes cluster.
