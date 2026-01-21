
#!/bin/bash

set -e

echo "=========================================="
echo "🚀 FINAL DEPLOYMENT - COMPLETE PLATFORM"
echo "=========================================="
echo ""

# Step 1: Build and push all images
echo "📦 Step 1: Building and pushing Docker images..."
./scripts/build-and-push.sh

# Step 2: Deploy complete stack
echo ""
echo "🏗️ Step 2: Deploying complete stack..."
./scripts/deploy-complete-stack.sh

# Step 3: Setup Vault
echo ""
echo "🔐 Step 3: Setting up Vault..."
./scripts/vault-setup.sh

# Step 4: Seed sample data
echo ""
echo "🌱 Step 4: Seeding sample data..."
echo "Waiting for services to be ready..."
sleep 30

kubectl run seed --rm -it --image=curlimages/curl --restart=Never -- \
  curl -X POST http://product-service:3002/api/products/seed

echo "✅ Sample products seeded"

# Step 5: Get access information
echo ""
echo "=========================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""

# Get Istio Ingress Gateway URL
GATEWAY_URL=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "🌐 Access URLs:"
echo ""
echo "   Frontend Application:"
echo "   http://$GATEWAY_URL"
echo ""
echo "   ArgoCD Dashboard:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   https://localhost:8080"
echo ""
echo "   Grafana (Monitoring):"
echo "   kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80"
echo "   http://localhost:3000 (admin/admin123)"
echo ""
echo "   Kiali (Service Mesh):"
echo "   kubectl port-forward svc/kiali -n istio-system 20001:20001"
echo "   http://localhost:20001"
echo ""
echo "   Vault UI:"
echo "   kubectl port-forward svc/vault-ui -n vault 8200:8200"
echo "   http://localhost:8200"
echo ""

echo "📊 Cluster Status:"
kubectl get nodes
echo ""
kubectl get pods --all-namespaces | grep -E "default|monitoring|vault|istio-system|argocd"

echo ""
echo "🎉 Your production-grade e-commerce platform is live!"
echo ""