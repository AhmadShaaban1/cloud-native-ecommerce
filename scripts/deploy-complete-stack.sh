#!/bin/bash

set -e

echo "=========================================="
echo "🚀 Complete Stack Deployment"
echo "=========================================="
echo ""

# Check prerequisites
echo "✅ Checking prerequisites..."

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl."
    exit 1
fi

# Check helm
if ! command -v helm &> /dev/null; then
    echo "❌ helm not found. Please install helm."
    exit 1
fi

# Check cluster connection
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to cluster. Please configure kubectl."
    exit 1
fi

echo "✅ All prerequisites met"
echo ""

# Step 1: Deploy base applications
echo "📦 Step 1/7: Deploying base applications..."
kubectl apply -f k8s/base/deployments/mongodb.yaml
kubectl apply -f k8s/base/deployments/redis.yaml

echo "⏳ Waiting for databases..."
kubectl wait --for=condition=ready pod -l app=mongodb --timeout=120s
kubectl wait --for=condition=ready pod -l app=redis --timeout=120s

kubectl apply -f k8s/base/deployments/user-service.yaml
kubectl apply -f k8s/base/deployments/product-service.yaml
kubectl apply -f k8s/base/deployments/order-service.yaml
kubectl apply -f k8s/base/deployments/payment-service.yaml

echo "⏳ Waiting for services..."
sleep 30

# Step 2: Install HashiCorp Vault
echo ""
echo "🔐 Step 2/7: Installing HashiCorp Vault..."

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm upgrade --install vault hashicorp/vault \
  --namespace vault \
  --create-namespace \
  --values k8s/vault/vault-values.yaml \
  --wait

echo "⏳ Waiting for Vault pods..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault -n vault --timeout=300s

echo ""
echo "🔑 Vault installed. Please initialize and unseal Vault manually:"
echo "   See docs/vault-setup.md for instructions"
echo ""

# Step 3: Install Istio
echo "🌐 Step 3/7: Installing Istio Service Mesh..."

if ! command -v istioctl &> /dev/null; then
    echo "📥 Downloading Istio..."
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.1 sh -
    cd istio-1.20.1
    export PATH=$PWD/bin:$PATH
    cd ..
fi

istioctl install --set profile=demo -y

echo "⏳ Waiting for Istio..."
kubectl wait --for=condition=ready pod -l app=istiod -n istio-system --timeout=300s

# Enable sidecar injection
kubectl label namespace default istio-injection=enabled --overwrite

# Apply Istio configs
kubectl apply -f k8s/istio/gateway.yaml
kubectl apply -f k8s/istio/destination-rules.yaml

echo "✅ Istio installed"

# Step 4: Install Kiali
echo ""
echo "📊 Step 4/7: Installing Kiali (Istio Dashboard)..."
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/prometheus.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/grafana.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/jaeger.yaml

# Step 5: Install ArgoCD
echo ""
echo "🔄 Step 5/7: Installing ArgoCD (GitOps)..."

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Waiting for ArgoCD..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Get ArgoCD password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "✅ ArgoCD installed"
echo "   Username: admin"
echo "   Password: $ARGOCD_PASSWORD"
echo "   (Save this password!)"

# Step 6: Deploy monitoring
echo ""
echo "📊 Step 6/7: Deploying monitoring stack..."
./scripts/install-monitoring-final.sh

# Step 7: Apply security policies
echo ""
echo "🔒 Step 7/7: Applying security policies..."
kubectl label namespace kube-system name=kube-system --overwrite
kubectl apply -f k8s/security/network-policies.yaml
kubectl apply -f k8s/security/rbac.yaml

echo ""
echo "=========================================="
echo "✅ COMPLETE STACK DEPLOYED!"
echo "=========================================="
echo ""

echo "📊 Cluster Status:"
kubectl get nodes
echo ""

echo "📦 Application Pods:"
kubectl get pods -n default
echo ""

echo "🔐 Vault Pods:"
kubectl get pods -n vault
echo ""

echo "🌐 Istio Pods:"
kubectl get pods -n istio-system
echo ""

echo "🔄 ArgoCD Pods:"
kubectl get pods -n argocd
echo ""

echo "📊 Monitoring Pods:"
kubectl get pods -n monitoring
echo ""

echo "🌐 Access URLs:"
echo "   ArgoCD:    kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   Grafana:   kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80"
echo "   Kiali:     kubectl port-forward svc/kiali -n istio-system 20001:20001"
echo "   Vault UI:  kubectl port-forward svc/vault-ui -n vault 8200:8200"
echo ""

echo "📚 Next Steps:"
echo "   1. Initialize and unseal Vault (see docs/vault-setup.md)"
echo "   2. Seed sample products: kubectl run seed --rm -it --image=curlimages/curl --restart=Never -- curl -X POST http://product-service:3002/api/products/seed"
echo "   3. Access dashboards using port-forward commands above"
echo "   4. Deploy frontend application"
echo ""