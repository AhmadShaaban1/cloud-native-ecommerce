#!/bin/bash

set -e

echo "=================================================="
echo "🔄 COMPLETE MONITORING STACK REINSTALL"
echo "=================================================="

# Step 1: Remove everything
echo ""
echo "🧹 Step 1: Removing all monitoring components..."
helm uninstall prometheus -n monitoring 2>/dev/null || true
helm uninstall loki -n monitoring 2>/dev/null || true
helm uninstall promtail -n monitoring 2>/dev/null || true

# Force delete all pods
kubectl delete pods --all -n monitoring --force --grace-period=0 2>/dev/null || true

# Delete PVCs
kubectl delete pvc --all -n monitoring 2>/dev/null || true

# Delete CRDs
echo "🧹 Removing Prometheus CRDs..."
kubectl delete crd prometheuses.monitoring.coreos.com 2>/dev/null || true
kubectl delete crd prometheusrules.monitoring.coreos.com 2>/dev/null || true
kubectl delete crd servicemonitors.monitoring.coreos.com 2>/dev/null || true
kubectl delete crd podmonitors.monitoring.coreos.com 2>/dev/null || true
kubectl delete crd alertmanagers.monitoring.coreos.com 2>/dev/null || true
kubectl delete crd alertmanagerconfigs.monitoring.coreos.com 2>/dev/null || true
kubectl delete crd thanosrulers.monitoring.coreos.com 2>/dev/null || true
kubectl delete crd probes.monitoring.coreos.com 2>/dev/null || true

echo "⏳ Waiting for cleanup (45 seconds)..."
sleep 45

# Verify namespace is clean
POD_COUNT=$(kubectl get pods -n monitoring --no-headers 2>/dev/null | wc -l)
echo "📊 Remaining pods: $POD_COUNT"

if [ "$POD_COUNT" -gt 0 ]; then
    echo "⚠️  Forcing final cleanup..."
    kubectl delete namespace monitoring --force --grace-period=0
    sleep 30
    kubectl create namespace monitoring
fi

# Step 2: Verify prerequisites
echo ""
echo "✅ Step 2: Verifying prerequisites..."

# Check nodes
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
echo "📊 Nodes available: $NODE_COUNT"

# Check StorageClass
kubectl get storageclass ebs-sc > /dev/null 2>&1 || {
    echo "❌ StorageClass ebs-sc not found!"
    exit 1
}
echo "✅ StorageClass verified"

# Step 3: Install Prometheus (without Alertmanager to save resources)
echo ""
echo "📊 Step 3: Installing Prometheus + Grafana..."
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values k8s/monitoring/prometheus-optimized.yaml \
  --set alertmanager.enabled=false \
  --timeout 15m

echo "⏳ Waiting for Prometheus pods (90 seconds)..."
sleep 90

# Check Prometheus status
PROM_READY=$(kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus --no-headers 2>/dev/null | grep -c "Running" || echo "0")
echo "📊 Prometheus pods running: $PROM_READY"

# Step 4: Install Loki
echo ""
echo "📝 Step 4: Installing Loki (SingleBinary)..."
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
  --timeout 10m

echo "⏳ Waiting for Loki (60 seconds)..."
sleep 60

# Step 5: Install Promtail
echo ""
echo "📋 Step 5: Installing Promtail..."
helm install promtail grafana/promtail \
  --namespace monitoring \
  --values k8s/monitoring/promtail-minimal.yaml

echo "⏳ Waiting for Promtail (45 seconds)..."
sleep 45

# Step 6: Restart Grafana
echo ""
echo "🔄 Step 6: Restarting Grafana..."
kubectl rollout restart deployment -n monitoring prometheus-grafana
kubectl rollout status deployment -n monitoring prometheus-grafana --timeout=120s

# Final verification
echo ""
echo "=================================================="
echo "✅ INSTALLATION COMPLETE"
echo "=================================================="
echo ""

echo "📊 Final Pod Status:"
kubectl get pods -n monitoring
echo ""

echo "💾 Storage Status:"
kubectl get pvc -n monitoring
echo ""

echo "🎯 Resource Usage:"
kubectl top nodes
echo ""

# Check for problems
echo "🔍 Checking for issues..."
PENDING=$(kubectl get pods -n monitoring --no-headers 2>/dev/null | grep -c "Pending" || echo "0")
CANARY=$(kubectl get pods -n monitoring --no-headers 2>/dev/null | grep -c "canary" || echo "0")

if [ "$PENDING" -gt 0 ]; then
    echo "⚠️  Warning: $PENDING pods are Pending"
    kubectl get pods -n monitoring | grep Pending
fi

if [ "$CANARY" -gt 0 ]; then
    echo "⚠️  Warning: Loki canary detected (should not exist!)"
    kubectl get pods -n monitoring | grep canary
fi

if [ "$PENDING" -eq 0 ] && [ "$CANARY" -eq 0 ]; then
    echo "✅ All checks passed!"
fi

echo ""
echo "🌐 Access Grafana:"
echo "   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "   URL: http://localhost:3000"
echo "   User: admin"
echo "   Pass: admin123"
echo ""