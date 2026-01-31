#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Installing Karpenter...${NC}"

# Configuration
export CLUSTER_NAME="ecommerce-dev"
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export KARPENTER_VERSION="v0.34.0"

echo "Cluster: $CLUSTER_NAME"
echo "Region: $AWS_REGION"
echo "Account: $AWS_ACCOUNT_ID"
echo "Karpenter Version: $KARPENTER_VERSION"

# Get cluster endpoint
CLUSTER_ENDPOINT=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${AWS_REGION} --query 'cluster.endpoint' --output text)
echo "Cluster Endpoint: $CLUSTER_ENDPOINT"

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}Helm is not installed. Please install Helm first.${NC}"
    exit 1
fi

# Add Karpenter Helm repository
echo -e "${YELLOW}Adding Karpenter Helm repository...${NC}"
helm repo add karpenter https://charts.karpenter.sh
helm repo update

# Check if namespace exists
if kubectl get namespace karpenter &> /dev/null; then
    echo -e "${YELLOW}Karpenter namespace already exists${NC}"
else
    echo -e "${YELLOW}Creating Karpenter namespace...${NC}"
    kubectl create namespace karpenter
fi

# Install or upgrade Karpenter
echo -e "${YELLOW}Installing Karpenter...${NC}"
helm upgrade --install karpenter \
  oci://public.ecr.aws/karpenter/karpenter \
  --namespace karpenter \
  --create-namespace \
  -f karpenter-values.yaml

# Verify installation
echo -e "${YELLOW}Verifying Karpenter installation...${NC}"
kubectl get pods -n karpenter
kubectl get deployment -n karpenter

# Check Karpenter logs
echo -e "${YELLOW}Checking Karpenter logs...${NC}"
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter --tail=20

# Install CRDs
echo -e "${YELLOW}Installing Karpenter CRDs...${NC}"
kubectl apply -f https://raw.githubusercontent.com/aws/karpenter-provider-aws/v1.8.6/pkg/apis/crds/karpenter.sh_nodepools.yaml
kubectl apply -f https://raw.githubusercontent.com/aws/karpenter-provider-aws/v1.8.6/pkg/apis/crds/karpenter.k8s.aws_ec2nodeclasses.yaml

# Install EC2NodeClass
echo -e "${YELLOW}Installing EC2NodeClass...${NC}"
kubectl apply -f ec2nodeclass.yaml

# Install NodePool
echo -e "${YELLOW}Installing NodePool...${NC}"
kubectl apply -f nodepool.yaml

echo -e "${GREEN}✅ Karpenter installation complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Apply the provisioner: kubectl apply -f k8s/karpenter/provisioner.yaml"
echo "2. Verify: kubectl get provisioners"
echo "3. Check logs: kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter"