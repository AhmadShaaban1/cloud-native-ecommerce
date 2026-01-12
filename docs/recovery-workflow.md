# Recovery Workflow After Terraform Destroy

## Prerequisites
Ensure you have:
- AWS CLI configured
- kubectl installed
- Helm installed
- All code committed to GitHub

## Step-by-Step Recovery

### 1. Recreate Infrastructure with Terraform
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply  # Takes 15-20 minutes

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name ecommerce-dev

# Verify cluster
kubectl get nodes
# Should see 8 nodes (based on your config)
```

### 2. Verify Prerequisites
```bash
# Check StorageClass
kubectl get storageclass ebs-sc

# If missing, recreate:
kubectl apply -f k8s/storage/storage-class.yaml

# Check EBS CSI Driver
kubectl get pods -n kube-system | grep ebs-csi

# If missing, reinstall (see Phase 3 docs)
```

### 3. Redeploy Application Services
```bash
# Rebuild and push images to ECR
./scripts/build-and-push.sh

# Deploy databases
kubectl apply -f k8s/base/deployments/mongodb.yaml
kubectl apply -f k8s/base/deployments/redis.yaml

# Wait for databases
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=120s
kubectl wait --for=condition=ready pod -l app=redis --timeout=120s

# Deploy microservices
kubectl apply -f k8s/base/deployments/user-service.yaml
kubectl apply -f k8s/base/deployments/product-service.yaml
kubectl apply -f k8s/base/deployments/order-service.yaml
kubectl apply -f k8s/base/deployments/payment-service.yaml

# Deploy ingress
kubectl apply -f k8s/ingress/ingress.yaml
```

### 4. Reinstall Monitoring Stack
```bash
./scripts/install-monitoring-final.sh
# Takes 5-7 minutes
```

### 5. Reapply Security Configurations
```bash
# Network policies
kubectl label namespace kube-system name=kube-system --overwrite
kubectl apply -f k8s/security/network-policies.yaml

# External Secrets
helm install external-secrets external-secrets/external-secrets \
  --namespace external-secrets-system \
  --create-namespace \
  --set installCRDs=true \
  --set resources.requests.cpu=50m \
  --set resources.requests.memory=64Mi

kubectl apply -f k8s/security/secret-store.yaml

# RBAC
kubectl apply -f k8s/security/rbac.yaml

# cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.0/cert-manager.yaml
kubectl apply -f k8s/security/cluster-issuer.yaml

# Trivy
helm install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --create-namespace
```

### 6. Verify Everything
```bash
# Run verification
./scripts/security-verification.sh

# Check all pods
kubectl get pods --all-namespaces

# Test services
kubectl get ingress
```

## Estimated Time: 30-40 minutes