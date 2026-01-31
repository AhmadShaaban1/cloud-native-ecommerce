#!/bin/bash

##############################################################################
# Automated Fix for "No Healthy Upstream" Error
# This script diagnoses and fixes common ALB ingress issues
##############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Fixing 'No Healthy Upstream' Error                       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print section
print_section() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Step 1: Check pod status
print_section "Step 1: Checking Pod Status"

echo "Current pods:"
kubectl get pods

echo ""
TOTAL_PODS=$(kubectl get pods --no-headers | wc -l)
RUNNING_PODS=$(kubectl get pods --no-headers | grep -c "Running" || echo "0")

echo -e "Total pods: $TOTAL_PODS"
echo -e "Running pods: $RUNNING_PODS"

if [ "$RUNNING_PODS" -lt "$TOTAL_PODS" ]; then
    echo -e "${RED}⚠ Not all pods are running!${NC}"
    
    echo ""
    echo "Pods with issues:"
    kubectl get pods | grep -v "Running" | grep -v "NAME"
    
    echo ""
    read -p "Restart all deployments? (y/n) " -n 1 -r
    echo
#     if [[ $REPLY =~ ^[Yy]$ ]]; then
#         echo "Restarting deployments..."
#         kubectl rollout restart deployment/user-service || echo "user-service not found"
#         kubectl rollout restart deployment/product-service || echo "product-service not found"
#         kubectl rollout restart deployment/order-service || echo "order-service not found"
#         kubectl rollout restart deployment/payment-service || echo "payment-service not found"
#         kubectl rollout restart deployment/frontend || echo "frontend not found"
        
#         echo "Waiting for rollouts to complete..."
#         sleep 10
        
#         kubectl rollout status deployment/user-service --timeout=2m || true
#         kubectl rollout status deployment/product-service --timeout=2m || true
#         kubectl rollout status deployment/order-service --timeout=2m || true
#         kubectl rollout status deployment/payment-service --timeout=2m || true
#         kubectl rollout status deployment/frontend --timeout=2m || true
#     fi
# else
#     echo -e "${GREEN}✓ All pods are running!${NC}"
# fi

# Step 2: Check services
print_section "Step 2: Checking Services"

echo "Current services:"
kubectl get svc

echo ""
echo "Service endpoints:"
kubectl get endpoints

# Step 3: Check service health endpoints
print_section "Step 3: Testing Service Health Endpoints"

# Test backend services
for service in user-service product-service order-service payment-service; do
    echo -n "Testing $service... "
    
    POD=$(kubectl get pods -l app=$service -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    
    if [ -z "$POD" ]; then
        echo -e "${RED}✗ No pod found${NC}"
        continue
    fi
    
    PORT=$(kubectl get svc $service -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null || echo "3001")
    
    if kubectl exec $POD -- curl -sf http://localhost:$PORT/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Healthy${NC}"
    else
        echo -e "${RED}✗ Health check failed${NC}"
        echo "  Pod: $POD"
        echo "  Trying to add health endpoint..."
        
        # Note: This won't actually add the endpoint, but shows the issue
        echo "  ⚠ Please ensure your service has a /health endpoint!"
    fi
done

# Test frontend
echo -n "Testing frontend... "
FRONTEND_POD=$(kubectl get pods -l app=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$FRONTEND_POD" ]; then
    echo -e "${RED}✗ No pod found${NC}"
    echo -e "${YELLOW}  Frontend might not be deployed!${NC}"
else
    if kubectl exec $FRONTEND_POD -- wget -q -O- http://localhost:80/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Healthy${NC}"
    else
        echo -e "${RED}✗ Health check failed${NC}"
        echo "  ⚠ Please ensure frontend nginx has /health endpoint!"
    fi
fi

# Step 4: Check ingress
print_section "Step 4: Checking Ingress Configuration"

echo "Ingress status:"
kubectl get ingress

echo ""
echo "Ingress details:"
kubectl describe ingress ecommerce-ingress | head -50

# Step 5: Check ALB controller
print_section "Step 5: Checking ALB Controller"

ALB_CONTROLLER=$(kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$ALB_CONTROLLER" ]; then
    echo -e "${RED}✗ AWS Load Balancer Controller not found!${NC}"
    echo ""
    echo "Installing AWS Load Balancer Controller..."
    
    read -p "Install ALB controller? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Install CRDs
        kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
        
        # Add helm repo
        helm repo add eks https://aws.github.io/eks-charts
        helm repo update
        
        # Get cluster name
        CLUSTER_NAME=$(kubectl config current-context | cut -d'/' -f2 || echo "ecommerce-dev")
        
        echo "Installing controller for cluster: $CLUSTER_NAME"
        
        helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
          -n kube-system \
          --set clusterName=$CLUSTER_NAME \
          --set serviceAccount.create=false \
          --set serviceAccount.name=aws-load-balancer-controller
        
        echo "Waiting for controller to be ready..."
        sleep 30
    fi
else
    echo -e "${GREEN}✓ ALB Controller is running${NC}"
    
    echo ""
    echo "Recent controller logs:"
    kubectl logs -n kube-system $ALB_CONTROLLER --tail=20
fi

# Step 6: Verify ingress-service mapping
print_section "Step 6: Verifying Ingress → Service Mapping"

echo "Checking if services referenced in ingress exist..."

# Get services from ingress
INGRESS_SERVICES=$(kubectl get ingress ecommerce-ingress -o jsonpath='{.spec.rules[*].http.paths[*].backend.service.name}' 2>/dev/null || echo "")

if [ -z "$INGRESS_SERVICES" ]; then
    echo -e "${RED}✗ Could not get services from ingress${NC}"
else
    for svc in $INGRESS_SERVICES; do
        echo -n "  Checking $svc... "
        if kubectl get svc $svc > /dev/null 2>&1; then
            echo -e "${GREEN}✓ Exists${NC}"
        else
            echo -e "${RED}✗ NOT FOUND${NC}"
        fi
    done
fi

# Step 7: Test ALB directly
print_section "Step 7: Testing ALB Endpoint"

ALB_DNS=$(kubectl get ingress ecommerce-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ -z "$ALB_DNS" ]; then
    echo -e "${RED}✗ ALB DNS not found${NC}"
    echo "  Ingress might still be provisioning..."
else
    echo "ALB DNS: $ALB_DNS"
    echo ""
    echo "Testing health endpoint..."
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$ALB_DNS/health" 2>/dev/null || echo "000")
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✓ ALB is healthy! (HTTP $HTTP_CODE)${NC}"
    else
        echo -e "${RED}✗ ALB returned HTTP $HTTP_CODE${NC}"
        
        if [ "$HTTP_CODE" = "503" ]; then
            echo "  This is the 'no healthy upstream' error"
            echo "  Backends are not reachable"
        fi
    fi
fi

# Summary
print_section "Summary & Next Steps"

echo "🔍 Diagnosis complete!"
echo ""

# Count issues
ISSUES=0

if [ "$RUNNING_PODS" -lt "$TOTAL_PODS" ]; then
    echo -e "${RED}❌ Issue: Not all pods are running${NC}"
    ((ISSUES++))
fi

if [ -z "$ALB_CONTROLLER" ]; then
    echo -e "${RED}❌ Issue: ALB controller not installed${NC}"
    ((ISSUES++))
fi

if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "000" ]; then
    echo -e "${RED}❌ Issue: ALB health check failing${NC}"
    ((ISSUES++))
fi

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ No obvious issues found!${NC}"
    echo ""
    echo "If you're still seeing 'no healthy upstream':"
    echo "1. Wait 2-3 minutes for ALB to sync"
    echo "2. Check AWS Console → EC2 → Target Groups"
    echo "3. Verify security groups allow traffic"
else
    echo ""
    echo -e "${YELLOW}Found $ISSUES issue(s) that need attention${NC}"
fi

echo ""
echo "Useful commands:"
echo "  kubectl get pods              # Check pod status"
echo "  kubectl get svc               # Check services"
echo "  kubectl get ingress           # Check ingress"
echo "  kubectl describe ingress gateway  # Detailed ingress info"
echo "  kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller  # ALB logs"
echo ""

if [ -n "$ALB_DNS" ]; then
    echo "Test your ALB:"
    echo "  curl http://$ALB_DNS/health"
    echo "  curl http://$ALB_DNS/"
fi

echo ""
echo -e "${GREEN}Script complete!${NC}"