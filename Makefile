.PHONY: help loadtest loadtest-randomized loadtest-arrival-rate loadtest-all clean-results swarm-deploy swarm-remove swarm-status autoscale-backend autoscale-frontend

# Default target
help:
	@echo "K6 Load Testing Makefile"
	@echo ""
	@echo "Load Testing Targets:"
	@echo "  make loadtest              - Run default predict.js test"
	@echo "  make loadtest-randomized   - Run randomized payload test"
	@echo "  make loadtest-arrival-rate - Run arrival-rate (RPS) test"
	@echo "  make loadtest-all          - Run all three tests sequentially"
	@echo "  make clean-results         - Remove all test results"
	@echo ""
	@echo "Docker Swarm Autoscaling Targets:"
	@echo "  make swarm-deploy          - Deploy to Docker Swarm with autoscaling support"
	@echo "  make swarm-status          - Show swarm services status"
	@echo "  make swarm-remove          - Remove swarm stack"
	@echo "  make autoscale-backend     - Start backend autoscaler (blocks terminal)"
	@echo "  make autoscale-frontend    - Start frontend autoscaler (blocks terminal)"
	@echo ""
	@echo "Environment variables:"
	@echo "  K6_VUS      - Number of virtual users (default: 10)"
	@echo "  K6_DURATION - Test duration (default: 30s)"
	@echo "  K6_RATE     - Requests per second for arrival-rate (default: 50)"
	@echo ""
	@echo "Examples:"
	@echo "  make loadtest K6_VUS=50 K6_DURATION=60s"
	@echo "  make loadtest-arrival-rate K6_RATE=100"
	@echo "  make swarm-deploy && make autoscale-backend"

# Variables
TIMESTAMP := $(shell date +"%Y%m%d_%H%M%S")
RESULTS_DIR := loadtests/results
BASE_URL ?= http://localhost:5000
K6_VUS ?= 10
K6_DURATION ?= 30s
K6_RATE ?= 50
K6_MAX_VUS ?= 100

# Create results directory if it doesn't exist
$(RESULTS_DIR):
	@mkdir -p $(RESULTS_DIR)

# Run default predict.js test
loadtest: $(RESULTS_DIR)
	@echo "Running default load test (predict.js)..."
	@echo "Timestamp: $(TIMESTAMP)" > $(RESULTS_DIR)/predict_$(TIMESTAMP).txt
	@echo "Script: loadtests/k6/predict.js" >> $(RESULTS_DIR)/predict_$(TIMESTAMP).txt
	@echo "VUs: $(K6_VUS), Duration: $(K6_DURATION)" >> $(RESULTS_DIR)/predict_$(TIMESTAMP).txt
	@echo "======================================" >> $(RESULTS_DIR)/predict_$(TIMESTAMP).txt
	@BASE_URL=$(BASE_URL) K6_VUS=$(K6_VUS) K6_DURATION=$(K6_DURATION) \
		k6 run loadtests/k6/predict.js 2>&1 | tee -a $(RESULTS_DIR)/predict_$(TIMESTAMP).txt
	@echo ""
	@echo "Results saved to: $(RESULTS_DIR)/predict_$(TIMESTAMP).txt"

# Run randomized payload test
loadtest-randomized: $(RESULTS_DIR)
	@echo "Running randomized payload test..."
	@echo "Timestamp: $(TIMESTAMP)" > $(RESULTS_DIR)/randomized_$(TIMESTAMP).txt
	@echo "Script: loadtests/k6/predict_randomized.js" >> $(RESULTS_DIR)/randomized_$(TIMESTAMP).txt
	@echo "VUs: $(K6_VUS), Duration: $(K6_DURATION)" >> $(RESULTS_DIR)/randomized_$(TIMESTAMP).txt
	@echo "======================================" >> $(RESULTS_DIR)/randomized_$(TIMESTAMP).txt
	@BASE_URL=$(BASE_URL) K6_VUS=$(K6_VUS) K6_DURATION=$(K6_DURATION) \
		k6 run loadtests/k6/predict_randomized.js 2>&1 | tee -a $(RESULTS_DIR)/randomized_$(TIMESTAMP).txt
	@echo ""
	@echo "Results saved to: $(RESULTS_DIR)/randomized_$(TIMESTAMP).txt"

# Run arrival-rate test
loadtest-arrival-rate: $(RESULTS_DIR)
	@echo "Running arrival-rate test..."
	@echo "Timestamp: $(TIMESTAMP)" > $(RESULTS_DIR)/arrival_rate_$(TIMESTAMP).txt
	@echo "Script: loadtests/k6/predict_arrival_rate.js" >> $(RESULTS_DIR)/arrival_rate_$(TIMESTAMP).txt
	@echo "Rate: $(K6_RATE) req/s, Duration: $(K6_DURATION), Max VUs: $(K6_MAX_VUS)" >> $(RESULTS_DIR)/arrival_rate_$(TIMESTAMP).txt
	@echo "======================================" >> $(RESULTS_DIR)/arrival_rate_$(TIMESTAMP).txt
	@BASE_URL=$(BASE_URL) K6_RATE=$(K6_RATE) K6_DURATION=$(K6_DURATION) K6_MAX_VUS=$(K6_MAX_VUS) \
		k6 run loadtests/k6/predict_arrival_rate.js 2>&1 | tee -a $(RESULTS_DIR)/arrival_rate_$(TIMESTAMP).txt
	@echo ""
	@echo "Results saved to: $(RESULTS_DIR)/arrival_rate_$(TIMESTAMP).txt"

# Run all tests
loadtest-all: $(RESULTS_DIR)
	@echo "Running all load tests sequentially..."
	@echo "======================================" 
	@$(MAKE) loadtest
	@echo ""
	@echo "Waiting 5 seconds before next test..."
	@sleep 5
	@$(MAKE) loadtest-randomized
	@echo ""
	@echo "Waiting 5 seconds before next test..."
	@sleep 5
	@$(MAKE) loadtest-arrival-rate
	@echo ""
	@echo "All tests completed! Results stored in $(RESULTS_DIR)/"

# Clean results directory
clean-results:
	@echo "Removing all test results..."
	@rm -rf $(RESULTS_DIR)/*.txt
	@echo "Results cleaned!"

# Docker Swarm Autoscaling Targets
swarm-deploy:
	@echo "🚀 Deploying to Docker Swarm with autoscaling support..."
	@./deploy-swarm.sh

swarm-status:
	@echo "📊 Swarm Services Status:"
	@docker stack services student-prediction 2>/dev/null || echo "Stack not deployed. Run 'make swarm-deploy' first."
	@echo ""
	@echo "📦 Service Details:"
	@docker stack ps student-prediction 2>/dev/null || true

swarm-remove:
	@echo "🛑 Removing swarm stack..."
	@docker stack rm student-prediction
	@echo "✅ Stack removed!"

autoscale-backend:
	@echo "🔄 Starting backend autoscaler (MIN=2, MAX=10, CPU=70%)"
	@echo "Press Ctrl+C to stop"
	@./autoscale.sh student-prediction_backend 2 10 70

autoscale-frontend:
	@echo "🔄 Starting frontend autoscaler (MIN=2, MAX=10, CPU=70%)"
	@echo "Press Ctrl+C to stop"
	@./autoscale.sh student-prediction_frontend 2 10 70
