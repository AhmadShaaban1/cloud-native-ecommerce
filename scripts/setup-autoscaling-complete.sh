#!/bin/bash

##############################################################################
# Complete Autoscaling Setup Script
# This script sets up Karpenter + HPA for the EKS cluster
##############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Print banner
clear
echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════════╗
║                                                                    ║
║     🚀 Kubernetes Autoscaling Setup                               ║
║     Karpenter + HPA + Metrics Server                              ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Configuration
CLUSTER_NAME="ecommerce-dev"
AWS_REGION="us-east-1"

echo -e "${PURPLE}Configuration:${NC}"
echo "  Cluster: $CLUSTER_NAME"
echo "  Region: $AWS_REGION"
echo ""

# Functions
print_step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  STEP $1: $2${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_step "1" "Checking Prerequisites"
    
    local missing=0
    
    # Check kubectl
    if command -v kubectl &> /dev/null; then
        print_success "kubectl installed"
    else
        print_error "kubectl not found"
        missing=1
    fi
    
    # Check helm
    if command -v helm &> /dev/null; then
        print_success "helm installed"
    else
        print_error "helm not found"
        missing=1
    fi
    
    # Check aws cli
    if command -v aws &> /dev/null; then
        print_success "aws cli installed"
    else
        print_error "aws cli not found"
        missing=1
    fi
    
    # Check cluster connection
    if kubectl cluster-info &> /dev/null; then
        print_success "Connected to Kubernetes cluster"
    else
        print_error "Cannot connect to Kubernetes cluster"
        print_warning "Run: aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME"
        missing=1
    fi
    
    if [ $missing -eq 1 ]; then
        print_error "Missing prerequisites. Please install missing tools and try again."
        exit 1
    fi
}

# Apply Terraform
apply_terraform() {
    print_step "2" "Applying Terraform Updates"
    
    read -p "Have you updated Terraform files with Karpenter configuration? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Applying Terraform...${NC}"
        cd terraform/environments/dev
        terraform init
        terraform apply
        cd ../../..
        print_success "Terraform applied"
    else
        print_warning "Skipping Terraform. Make sure to apply it manually!"
    fi
}

# Install Metrics Server
install_metrics_server() {
    print_step "3" "Installing Metrics Server"
    
    chmod +x ../k8s/autoscaling/install-metrics-server.sh
    ./../k8s/autoscaling/install-metrics-server.sh
    
    print_success "Metrics Server installed"
}

# Install Karpenter
install_karpenter() {
    print_step "4" "Installing Karpenter"
    
    chmod +x ../k8s/karpenter/install-karpenter.sh
    ./../k8s/karpenter/install-karpenter.sh
    
    print_success "Karpenter installed"
}

# Apply Karpenter Provisioner
apply_provisioner() {
    print_step "5" "Configuring Karpenter Provisioner"
    
    kubectl apply -f ../k8s/karpenter/provisioner.yaml
    
    echo ""
    echo -e "${YELLOW}Verifying provisioner...${NC}"
    kubectl get provisioners
    kubectl get awsnodetemplates
    
    print_success "Karpenter provisioner configured"
}

# Apply HPAs
apply_hpas() {
    print_step "6" "Setting Up Horizontal Pod Autoscalers"
    
    kubectl apply -f ../k8s/autoscaling/all-services-hpa.yaml
    
    echo ""
    echo -e "${YELLOW}HPA Status:${NC}"
    kubectl get hpa
    
    print_success "HPAs configured"
}

# Apply Pod Disruption Budgets
apply_pdbs() {
    print_step "7" "Configuring Pod Disruption Budgets"
    
    kubectl apply -f ../k8s/autoscaling/pod-disruption-budgets.yaml
    
    echo ""
    echo -e "${YELLOW}PDB Status:${NC}"
    kubectl get pdb
    
    print_success "Pod Disruption Budgets configured"
}

# Verify installation
verify_installation() {
    print_step "8" "Verifying Installation"
    
    echo -e "${YELLOW}Checking all components...${NC}"
    echo ""
    
    echo -e "${PURPLE}Metrics Server:${NC}"
    kubectl get deployment metrics-server -n kube-system
    
    echo ""
    echo -e "${PURPLE}Karpenter:${NC}"
    kubectl get pods -n karpenter
    
    echo ""
    echo -e "${PURPLE}Provisioners:${NC}"
    kubectl get provisioners
    
    echo ""
    echo -e "${PURPLE}HPAs:${NC}"
    kubectl get hpa
    
    echo ""
    echo -e "${PURPLE}PDBs:${NC}"
    kubectl get pdb
    
    echo ""
    echo -e "${PURPLE}Current Nodes:${NC}"
    kubectl get nodes
    
    print_success "Verification complete"
}

# Print next steps
print_next_steps() {
    echo ""
    echo -e "${GREEN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════════╗
║                                                                    ║
║     🎉 Autoscaling Setup Complete!                                ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${PURPLE}What's Been Configured:${NC}"
    echo "  ✅ Metrics Server - Provides CPU/memory metrics"
    echo "  ✅ Karpenter - Automatic node scaling"
    echo "  ✅ HPAs - Automatic pod scaling (2-10 replicas)"
    echo "  ✅ PDBs - High availability during updates"
    echo ""
    
    echo -e "${PURPLE}Your Cluster Can Now:${NC}"
    echo "  🚀 Auto-scale pods from 2 to 10 based on load"
    echo "  🚀 Auto-add nodes when pods are pending"
    echo "  🚀 Auto-remove empty nodes after 30 seconds"
    echo "  🚀 Maintain zero downtime during scaling"
    echo ""
    
    echo -e "${PURPLE}Test Autoscaling:${NC}"
    echo "  ${YELLOW}# Run test script${NC}"
    echo "  chmod +x scripts/test-autoscaling.sh"
    echo "  ./scripts/test-autoscaling.sh"
    echo ""
    echo "  ${YELLOW}# Generate load (requires 'hey' tool)${NC}"
    ALB_DNS=$(kubectl get ingress ecommerce-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "your-alb-dns")
    echo "  hey -z 5m -c 50 http://$ALB_DNS/api/users/health"
    echo ""
    echo "  ${YELLOW}# Watch scaling in action${NC}"
    echo "  kubectl get hpa --watch"
    echo "  kubectl get nodes --watch"
    echo ""
    
    echo -e "${PURPLE}Monitor Autoscaling:${NC}"
    echo "  kubectl top nodes                      # Node CPU/memory"
    echo "  kubectl top pods                       # Pod CPU/memory"
    echo "  kubectl get hpa                        # HPA status"
    echo "  kubectl describe hpa user-service-hpa  # Detailed HPA info"
    echo "  kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter  # Karpenter logs"
    echo ""
    
    echo -e "${PURPLE}Cost Savings Enabled:${NC}"
    echo "  💰 Nodes removed when empty (saves $$$)"
    echo "  💰 Pods scaled down during low traffic"
    echo "  💰 Only pay for what you use"
    echo ""
    
    echo -e "${GREEN}🎊 Your cluster is now production-ready with autoscaling! 🎊${NC}"
    echo ""
}

# Main execution
main() {
    check_prerequisites
    
    # Ask for confirmation
    echo -e "${YELLOW}This script will:${NC}"
    echo "  1. Apply Terraform updates (optional)"
    echo "  2. Install Metrics Server"
    echo "  3. Install Karpenter"
    echo "  4. Configure autoscaling"
    echo ""
    read -p "Continue? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    
    apply_terraform
    install_metrics_server
    install_karpenter
    apply_provisioner
    apply_hpas
    apply_pdbs
    verify_installation
    print_next_steps
}

# Run main
main