
#!/bin/bash

set -e

echo "=========================================="
echo "🚀 FINAL DEPLOYMENT - COMPLETE PLATFORM"
echo "=========================================="
echo ""

REGION="us-east-1"
CLUSTER_NAME="ecommerce-dev"

echo "🔹 Updating kubeconfig..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
echo "🔹 Waiting for nodes to be Ready..."
kubectl wait --for=condition=Ready node --all --timeout=300s

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
POLICY_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:policy/ebs-csi-policy"

# aws eks describe-cluster \
#   --name ecommerce-dev \
#   --query "cluster.identity.oidc.issuer" \
#   --output text

# verify if ebs-csi-controller is installed
echo "🔹 Checking for EBS CSI Driver..."
if ! kubectl get deployment ebs-csi-controller -n kube-system >/dev/null 2>&1; then
  echo "➕ Installing EBS CSI Driver"
  helm upgrade --install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  --set controller.serviceAccount.create=true \
  --set controller.serviceAccount.name=ebs-csi-controller-sa
fi

echo "🔹 Verifying StorageClass..."
if ! kubectl get storageclass ebs-sc >/dev/null 2>&1; then
  echo "➕ Applying StorageClass"
  kubectl apply -f ../k8s/storage/storage-class.yaml
fi

# Step 1: Build and push all images
echo "📦 Step 1: Building and pushing Docker images..."
./build-and-push.sh

# Step 2: Deploy complete stack
echo ""
echo "🏗️ Step 2: Deploying complete stack..."
./deploy-complete-stack.sh

step 3: Setup autoscaling
echo ""
echo "📈 Step 3: Setting up autoscaling..."
./setup-autoscaling-complete.sh

# Step 4: Setup Vault
echo ""
echo "🔐 Step 4: Setting up Vault..."
./vault-setup.sh

# Step 5: Seed sample data
echo ""
echo "🌱 Step 5: Seeding sample data..."
echo "Waiting for services to be ready..."
sleep 30

kubectl exec -it product-service-5b6f4595ff-vsnhp -- curl -X POST http://product-service:3002/api/products/seed

echo "✅ Sample products seeded"

# Step 5: Get access information
echo ""
echo "=========================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""

# # Get Istio Ingress Gateway URL
# GATEWAY_URL=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

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