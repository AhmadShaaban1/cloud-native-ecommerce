#!/bin/bash

set -e

# echo "=================================================="
# echo "🚀 FINAL MONITORING STACK INSTALLATION"
# echo "=================================================="
# echo ""

# # Check nodes
# NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
# echo "📊 Current nodes: $NODE_COUNT"

# if [ $NODE_COUNT -lt 4 ]; then
#     echo "⚠️  Warning: Less than 4 nodes. Monitoring may have resource issues."
#     echo "   Recommended: Scale to 4 nodes first"
#     read -p "Continue anyway? (y/n) " -n 1 -r
#     echo
#     if [[ ! $REPLY =~ ^[Yy]$ ]]; then
#         exit 1
#     fi
# fi

# echo ""
# echo "🧹 Step 1: Complete cleanup..."
# helm uninstall prometheus -n monitoring 2>/dev/null || true
# helm uninstall loki -n monitoring 2>/dev/null || true
# helm uninstall promtail -n monitoring 2>/dev/null || true

# kubectl delete namespace monitoring --force --grace-period=0 2>/dev/null || true

# echo "⏳ Waiting for cleanup (30s)..."
# sleep 30

# echo ""
# echo "📦 Step 2: Create monitoring namespace..."
# kubectl create namespace monitoring

echo ""
echo "💾 Step 3: Verify StorageClass exists..."
kubectl get storageclass ebs-sc || {
    echo "❌ StorageClass ebs-sc not found!"
    echo "Creating it now..."
    kubectl apply -f ../k8s/storage/storage-class.yaml
}

echo ""
echo "📊 Step 4: Installing Prometheus + Grafana..."
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values ../k8s/monitoring/prometheus-optimized.yaml \
  --timeout 15m

echo "⏳ Waiting for Prometheus (60s)..."
sleep 60

echo ""
echo "📝 Step 5: Installing Loki..."
helm install loki grafana/loki \
  --namespace monitoring \
  --values k8s/monitoring/loki-minimal.yaml \
  --set deploymentMode=SingleBinary \
  --set singleBinary.replicas=1 \
  --set monitoring.lokiCanary.enabled=false \
  --set lokiCanary.enabled=false \
  --set write.replicas=0 \
  --set read.replicas=0 \
  --set backend.replicas=0 \
  --set chunksCache.enabled=false \
  --set chunksCache.replicas=0 \
  --set resultsCache.enabled=false \
  --set resultsCache.replicas=0 \
  --timeout 10m

echo "⏳ Waiting for Loki (45s)..."
sleep 45

echo ""
echo "📋 Step 6: Installing Promtail..."
helm install promtail grafana/promtail \
  --namespace monitoring \
  --values ../k8s/monitoring/promtail-minimal.yaml

echo "⏳ Waiting for Promtail (30s)..."
sleep 30

echo ""
echo "🔄 Step 7: Restarting Grafana to pick up Loki datasource..."
kubectl rollout restart deployment -n monitoring prometheus-grafana

echo "⏳ Waiting for Grafana (45s)..."
sleep 45

echo ""
echo "=================================================="
echo "✅ INSTALLATION COMPLETE!"
echo "=================================================="
echo ""

echo "📊 Pod Status:"
kubectl get pods -n monitoring
echo ""

echo "💾 Storage Status:"
kubectl get pvc -n monitoring
echo ""

echo "🌐 Access Grafana:"
echo "   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "   URL: http://localhost:3000"
echo "   Username: admin"
echo "   Password: admin123"
echo ""

echo "🔍 Test Loki connection:"
echo "   kubectl port-forward -n monitoring svc/loki-gateway 3100:80"
echo "   curl http://localhost:3100/ready"
echo ""

echo "📈 Verify all pods are running:"
echo "   kubectl get pods -n monitoring"
echo ""