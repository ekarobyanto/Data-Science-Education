# Nginx Load Balancer Configuration

This nginx configuration provides load balancing for the backend and frontend services.

## Architecture

```
Host Machine (localhost)
    ↓
Nginx Load Balancer (ports 5000, 3000)
    ↓
├─→ Backend Replicas (2 instances, round-robin)
│   ├─ backend-1 (1 CPU, 1GB RAM)
│   └─ backend-2 (1 CPU, 1GB RAM)
│
└─→ Frontend Replicas (1 instances, round-robin)
    └─ frontend-1 (1 CPU, 1GB RAM)
```

## Load Balancing Strategy

- **Method**: Round-robin (default nginx behavior)
- **Backend**: Distributes API requests across 2 backend instances
- **Frontend**: Distributes UI requests across 1 frontend instance

## Access Points

- **Backend API**: http://localhost:5000
- **Frontend UI**: http://localhost:3000

All requests are automatically distributed across available healthy replicas.

## Resource Limits

Each service instance is limited to:
- 1 CPU core maximum
- 1GB RAM maximum
- Reserved: 0.5 CPU and 512MB RAM (backend), 0.25 CPU and 256MB RAM (frontend)

Total maximum resource usage:
- 4 CPUs (2 backend + 2 frontend)
- 4GB RAM (2GB backend + 2GB frontend)
