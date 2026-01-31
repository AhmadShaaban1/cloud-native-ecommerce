#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Testing Kubernetes Autoscaling                    ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo ""

# Function to print section header
print_section() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# 1. Check Metrics Server
print_section "1. Checking Metrics Server"
echo -e "${YELLOW}Metrics Server status:${NC}"
kubectl get deployment metrics-server -n kube-system

echo ""
echo -e "${YELLOW}Testing node metrics:${NC}"
kubectl top nodes || echo -e "${RED}Metrics not available yet${NC}"

echo ""
echo -e "${YELLOW}Testing pod metrics:${NC}"
kubectl top pods -n default || echo -e "${RED}Metrics not available yet${NC}"

# 2. Check Karpenter
print_section "2. Checking Karpenter"
echo -e "${YELLOW}Karpenter deployment:${NC}"
kubectl get deployment -n karpenter

echo ""
echo -e "${YELLOW}Karpenter pods:${NC}"
kubectl get pods -n karpenter

echo ""
echo -e "${YELLOW}Karpenter provisioners:${NC}"
kubectl get provisioners

echo ""
echo -e "${YELLOW}Karpenter node templates:${NC}"
kubectl get awsnodetemplates

# 3. Check HPAs
print_section "3. Checking Horizontal Pod Autoscalers"
kubectl get hpa

echo ""
echo -e "${YELLOW}Detailed HPA status:${NC}"
kubectl get hpa -o wide

# 4. Check current pod counts
print_section "4. Current Pod Counts"
echo -e "${YELLOW}User Service:${NC} $(kubectl get pods -l app=user-service -o json | jq '.items | length')"
echo -e "${YELLOW}Product Service:${NC} $(kubectl get pods -l app=product-service -o json | jq '.items | length')"
echo -e "${YELLOW}Order Service:${NC} $(kubectl get pods -l app=order-service -o json | jq '.items | length')"
echo -e "${YELLOW}Payment Service:${NC} $(kubectl get pods -l app=payment-service -o json | jq '.items | length')"
echo -e "${YELLOW}Frontend:${NC} $(kubectl get pods -l app=frontend -o json | jq '.items | length')"

# 5. Check Pod Disruption Budgets
print_section "5. Checking Pod Disruption Budgets"
kubectl get pdb

# 6. Test HPA with load (optional)
print_section "6. Load Testing (Optional)"
echo "To test HPA scaling, you can generate load using:"
echo ""
echo -e "${GREEN}# Install hey (load testing tool)${NC}"
echo "brew install hey  # macOS"
echo "# or download from: https://github.com/rakyll/hey"
echo ""
echo -e "${GREEN}# Generate load to user service${NC}"
ALB_DNS=$(kubectl get ingress ecommerce-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "ALB_NOT_FOUND")
if [ "$ALB_DNS" != "ALB_NOT_FOUND" ]; then
    echo "hey -z 5m -c 50 http://$ALB_DNS/api/users/health"
    echo ""
    echo -e "${GREEN}# Watch HPA in real-time${NC}"
    echo "kubectl get hpa --watch"
else
    echo -e "${RED}ALB not found. Make sure ingress is deployed.${NC}"
fi

# 7. Test Karpenter node scaling
print_section "7. Testing Karpenter Node Scaling"
echo "To test Karpenter node scaling:"
echo ""
echo -e "${GREEN}# Create high-resource deployment${NC}"
echo "kubectl apply -f k8s/autoscaling/test-inflate.yaml"
echo ""
echo -e "${GREEN}# Watch nodes being created${NC}"
echo "kubectl get nodes --watch"
echo ""
echo -e "${GREEN}# Watch Karpenter logs${NC}"
echo "kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter"
echo ""
echo -e "${GREEN}# Clean up test deployment${NC}"
echo "kubectl delete -f k8s/autoscaling/test-inflate.yaml"

# Summary
print_section "Summary"
echo -e "${GREEN}✅ Autoscaling components checked${NC}"
echo ""
echo "Current node count: $(kubectl get nodes --no-headers | wc -l)"
echo "Current pod count: $(kubectl get pods --no-headers | wc -l)"
echo ""
echo -e "${YELLOW}Monitoring commands:${NC}"
echo "  kubectl get hpa --watch              # Watch HPA status"
echo "  kubectl get nodes --watch            # Watch node count"
echo "  kubectl top nodes                    # Node resource usage"
echo "  kubectl top pods                     # Pod resource usage"
echo "  kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter  # Karpenter logs"
echo ""echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"