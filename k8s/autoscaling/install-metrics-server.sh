#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Installing Metrics Server...${NC}"

# Install Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Wait for metrics server to be ready
echo -e "${YELLOW}Waiting for Metrics Server to be ready...${NC}"
kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=300s

# Verify installation
echo -e "${YELLOW}Verifying Metrics Server...${NC}"
kubectl get deployment metrics-server -n kube-system

# Test metrics
echo -e "${YELLOW}Testing metrics collection...${NC}"
echo "Waiting 30 seconds for metrics to be collected..."
sleep 30

echo -e "${YELLOW}Node metrics:${NC}"
kubectl top nodes || echo "Metrics not ready yet, this is normal on first install"

echo -e "${YELLOW}Pod metrics:${NC}"
kubectl top pods -A || echo "Metrics not ready yet, this is normal on first install"

echo -e "${GREEN}✅ Metrics Server installation complete!${NC}"
echo ""
echo "Note: It may take a few minutes for metrics to be available."
echo "You can check with: kubectl top nodes"