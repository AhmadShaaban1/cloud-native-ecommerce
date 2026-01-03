#!/bin/bash

set -e

echo "🧹 Removing incorrect Loki installation..."
helm uninstall loki -n monitoring 2>/dev/null || true
helm uninstall promtail -n monitoring 2>/dev/null || true

kubectl delete pods -n monitoring -l app.kubernetes.io/name=loki --force --grace-period=0 2>/dev/null || true
kubectl delete pvc -n monitoring -l app.kubernetes.io/name=loki 2>/dev/null || true

echo "⏳ Waiting for cleanup..."
sleep 20

echo "📝 Installing Loki in SingleBinary mode..."
helm install loki grafana/loki \
  --namespace monitoring \
  --values k8s/monitoring/loki-values.yaml \
  --set deploymentMode=SingleBinary \
  --set singleBinary.replicas=1 \
  --set write.replicas=0 \
  --set read.replicas=0 \
  --set backend.replicas=0 \
  --set monitoring.lokiCanary.enabled=false \
  --set chunksCache.enabled=false \
  --set resultsCache.enabled=false \
  --timeout 10m

echo "⏳ Waiting for Loki pods..."
sleep 30

echo "📋 Installing Promtail..."
helm install promtail grafana/promtail \
  --namespace monitoring \
  --values k8s/monitoring/promtail-values.yaml

echo "⏳ Waiting for Promtail..."
sleep 20

echo ""
echo "✅ Loki stack reinstalled!"
echo ""
echo "📊 Check pods:"
kubectl get pods -n monitoring | grep -E "loki|promtail"