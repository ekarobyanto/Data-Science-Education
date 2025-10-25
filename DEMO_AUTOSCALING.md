# Autoscaling Demo Guide

This guide shows you how to test and demonstrate the autoscaling functionality.

## Understanding the Issue

The Flask backend ML prediction service is **very lightweight and fast**:
- ML predictions complete in ~10-50ms
- CPU usage stays at 0.3-0.5% even under 500-1000 concurrent users
- The production threshold (70% CPU) would require extreme load that crashes connection limits before CPU spikes

## Solution: Demo Autoscaler

We've created `autoscale-demo.sh` with a **5% CPU threshold** specifically for demonstration purposes.

## How to Test Autoscaling

### Option 1: Automated Demo (Recommended)

Run the existing automated demo script:

```bash
# Start the automated demo
./demo-autoscaling.sh

# This will:
# 1. Check services are running
# 2. Start autoscaler with 5% threshold in background
# 3. Run moderate load test (100 VUs for 60s)
# 4. Monitor replica scaling
```

### Option 2: Manual Testing (Step by Step)

**Terminal 1 - Monitor Services:**
```bash
# Watch service replica counts update in real-time
watch -n 2 'docker service ls | grep student-prediction'
```

**Terminal 2 - Run Demo Autoscaler:**
```bash
# Start autoscaler with 5% CPU threshold
# Syntax: ./autoscale-demo.sh <service> <min> <max> <cpu_threshold>
./autoscale-demo.sh student-prediction_backend 2 6 5
```

This will output:
- Current replica count
- Average CPU usage across all replicas
- Scaling decisions (up/down/none)

**Terminal 3 - Generate Load:**
```bash
# Run moderate load test to trigger CPU >5%
make loadtest K6_VUS=50 K6_DURATION=120s

# OR for more aggressive load:
make loadtest K6_VUS=100 K6_DURATION=120s
```

**What to Expect:**
1. Initially: 2 backend replicas running at ~0.3% CPU
2. After load starts: CPU rises to 2-8%
3. When CPU >5%: Autoscaler scales from 2 → 4 replicas
4. With more replicas: Load distributed, CPU drops below 2%
5. When CPU <2%: Autoscaler scales down 4 → 2 replicas

### Option 3: Quick Verification

Just check if scaling works:

```bash
# 1. Current state
docker service ls | grep backend

# 2. Start demo autoscaler in background
./autoscale-demo.sh student-prediction_backend 2 6 5 &
AUTOSCALER_PID=$!

# 3. Generate load
make loadtest K6_VUS=75 K6_DURATION=60s

# 4. Watch replicas scale up
docker service ls | grep backend

# 5. Wait for load to finish, watch scale down
sleep 90
docker service ls | grep backend

# 6. Stop autoscaler
kill $AUTOSCALER_PID
```

## Comparison: Production vs Demo Thresholds

| Threshold | Use Case | Triggers At | Suitable For |
|-----------|----------|-------------|--------------|
| **70% CPU** (production) | Real workloads | High sustained load | Production deployment |
| **5% CPU** (demo) | Testing/demonstration | Light to moderate load | Local testing, demos |

## Why Autoscaling "Didn't Work" Before

The production `autoscale.sh` uses 70% CPU threshold. Your Flask backend:
- Handles 500 VUs at only 0.35% CPU
- Would need 100,000+ VUs to reach 70% (impossible due to connection limits)
- Connection pool exhaustion (EOF errors) happens before CPU stress

## Tuning for Real Production

For production deployment, consider:

1. **Multi-metric autoscaling** - Add:
   - Request rate (RPS)
   - Response time (p95 latency)
   - Memory usage
   - Active connections

2. **Lower CPU threshold** for I/O-bound services:
   ```bash
   ./autoscale.sh student-prediction_backend 2 10 30  # 30% instead of 70%
   ```

3. **Kubernetes HPA** for cloud deployments (supports multiple metrics)

## Troubleshooting

**Autoscaling not triggering?**
- Check Docker stats: `docker stats --no-stream | grep backend`
- CPU might already be below threshold
- Increase load: `K6_VUS=150`

**Connection errors during load test?**
- Normal at high VU counts (2000+)
- Backend connection pool exhausted
- Reduce VUs or increase test duration

**Scaling too aggressive?**
- Increase `CHECK_INTERVAL` in autoscaler
- Adjust `SCALE_UP_BY` and `SCALE_DOWN_BY` parameters

## Files Reference

- `autoscale.sh` - Production autoscaler (70% CPU)
- `autoscale-demo.sh` - Demo autoscaler (5% CPU)
- `demo-autoscaling.sh` - Automated demo script
- `docker-stack.yml` - Swarm service definitions
- `AUTOSCALING.md` - Complete autoscaling documentation
