#!/usr/bin/env bash
set -e

echo "======================================"
echo "🚨 EKS Disaster Recovery Started"
echo "======================================"

REGION="us-east-1"
CLUSTER_NAME="ecommerce-dev"

echo "🔹 Updating kubeconfig..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

echo "🔹 Waiting for nodes to be Ready..."
kubectl wait --for=condition=Ready node --all --timeout=300s

echo "🔹 Verifying StorageClass..."
if ! kubectl get storageclass ebs-sc >/dev/null 2>&1; then
  echo "➕ Applying StorageClass"
  kubectl apply -f ../k8s/storage/storage-class.yaml
fi

echo "🔹 Deploying Databases..."
kubectl apply -f k8s/base/deployments/mongodb.yaml
kubectl apply -f k8s/base/deployments/redis.yaml

echo "⏳ Waiting for Databases..."
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=180s
kubectl wait --for=condition=ready pod -l app=redis --timeout=180s

echo "🔹 Deploying Microservices..."
kubectl apply -f k8s/base/deployments/user-service.yaml
kubectl apply -f k8s/base/deployments/product-service.yaml
kubectl apply -f k8s/base/deployments/order-service.yaml
kubectl apply -f k8s/base/deployments/payment-service.yaml

echo "🔹 Deploying Ingress..."
kubectl apply -f k8s/ingress/ingress.yaml

echo "🔹 Installing Monitoring..."
./scripts/install-monitoring-final.sh

echo "🔹 Applying Security Configurations..."
kubectl apply -f k8s/security/network-policies.yaml
kubectl apply -f k8s/security/rbac.yaml
kubectl apply -f k8s/security/cluster-issuer.yaml

echo "🔹 Final Health Check..."
kubectl get pods --all-namespaces
kubectl get ingress
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl wait --for=condition=ready pod -l app=metrics-server -n kube-system --timeout=180s
kubectl top nodes
echo "🔹 Verifying Microservices..."

echo "======================================"
echo "✅ Disaster Recovery Completed"
echo "======================================"
