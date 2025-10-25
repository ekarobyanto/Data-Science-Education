# Load tests (k6)

This folder contains k6 load test scripts for the backend API.

Files:
- `k6/predict.js` - default load test. Hits `/`, `/model-info`, and `POST /predict` using an example payload.
- `k6/predict_randomized.js` - randomized payload generator. Each VU generates random student data to test label encoding and edge cases.
- `k6/predict_arrival_rate.js` - constant-arrival-rate scenario (target RPS). Uses randomized payloads with a realistic throughput pattern.
- `k6/train_caution.js` - CAUTION: triggers `/train`. Runs with a single VU and short duration. Use only intentionally.

Quick run examples:

1) Run locally (if you have k6 installed):

```bash
k6 run loadtests/k6/predict.js
```

You can tune VUs and duration with environment variables:

```bash
BASE_URL=http://localhost:5000 K6_VUS=50 K6_DURATION=60s k6 run loadtests/k6/predict.js
```

Run the randomized payload script:

```bash
k6 run loadtests/k6/predict_randomized.js
```

Run the arrival-rate scenario (target 50 RPS for 1 minute):

```bash
k6 run loadtests/k6/predict_arrival_rate.js
```

Customize the arrival-rate scenario:

```bash
K6_RATE=100 K6_DURATION=2m K6_MAX_VUS=200 k6 run loadtests/k6/predict_arrival_rate.js
```

Available environment variables for `predict_arrival_rate.js`:
- `K6_RATE` - target requests per second (default: 50)
- `K6_DURATION` - test duration (default: 1m)
- `K6_PRE_ALLOCATED_VUS` - pre-allocated VUs (default: 10)
- `K6_MAX_VUS` - max VUs if needed (default: 100)

2) Run with Docker (no local k6 install required):

```bash
docker run --rm -v "$PWD":/scripts -w /scripts -e BASE_URL=http://host.docker.internal:5000 grafana/k6 run loadtests/k6/predict.js
```

Run the randomized script:

```bash
docker run --rm -v "$PWD":/scripts -w /scripts -e BASE_URL=http://host.docker.internal:5000 grafana/k6 run loadtests/k6/predict_randomized.js
```

Run the arrival-rate script with custom RPS:

```bash
docker run --rm -v "$PWD":/scripts -w /scripts \
  -e BASE_URL=http://host.docker.internal:5000 \
  -e K6_RATE=100 \
  -e K6_DURATION=2m \
  grafana/k6 run loadtests/k6/predict_arrival_rate.js
```

Note on `/train` endpoint
- The `/train` endpoint will retrain the model and may be slow and resource intensive. Only use `k6/train_caution.js` when you intend to exercise training and with very low load.

Run with Docker Compose
-----------------------

If you prefer to run k6 as a service alongside the backend using Docker Compose, there's a helper compose file and script in `loadtests/`.

From the project root run:

```bash
./loadtests/run_k6_docker.sh
```

This will combine the repository `docker-compose.yml` with `loadtests/docker-compose.k6.yml` and run k6 targeting the `backend` service on the same Docker network. The k6 container runs `loadtests/k6/predict.js` by default.

To run a different script or customize parameters, set environment variables:

```bash
# Run the randomized payload script
K6_SCRIPT=predict_randomized.js ./loadtests/run_k6_docker.sh

# Run the arrival-rate script with custom RPS
K6_SCRIPT=predict_arrival_rate.js K6_RATE=100 K6_DURATION=2m ./loadtests/run_k6_docker.sh

# Run the default script with more VUs
K6_VUS=50 K6_DURATION=60s ./loadtests/run_k6_docker.sh
```

Available environment variables:
- `K6_SCRIPT` - script filename (default: predict.js)
- `K6_VUS` - number of virtual users for VU-based scripts (default: 10)
- `K6_DURATION` - test duration (default: 30s)
- `K6_RATE` - requests per second for arrival-rate script (default: 50)
- `K6_MAX_VUS` - max VUs for arrival-rate script (default: 100)

Notes:
- `loadtests/docker-compose.k6.yml` expects the `app-network` network to exist (it's declared in the main `docker-compose.yml`).
- The script tries `docker compose` first and falls back to `docker-compose`.
- Backend and frontend services each run with 2 replicas, limited to 1 CPU and 1GB RAM per instance.
- An nginx load balancer distributes traffic across replicas using round-robin.
- Access the services via nginx on localhost:5000 (backend) and localhost:3000 (frontend).

Using Makefile (Recommended)
----------------------------

A Makefile is provided at the project root to simplify running tests and storing results with timestamps.

From the project root:

```bash
# Show available targets
make help

# Run default test (saves to loadtests/results/predict_YYYYMMDD_HHMMSS.txt)
make loadtest

# Run randomized payload test
make loadtest-randomized

# Run arrival-rate test
make loadtest-arrival-rate

# Run all three tests sequentially
make loadtest-all

# Customize parameters
make loadtest K6_VUS=50 K6_DURATION=60s
make loadtest-arrival-rate K6_RATE=100 K6_DURATION=2m

# Clean all results
make clean-results
```

Test results are automatically saved to `loadtests/results/` with timestamps for easy tracking.
