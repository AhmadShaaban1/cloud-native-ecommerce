#!/bin/bash

set -e

echo "🧹 Cleaning up old installations..."
helm uninstall prometheus -n monitoring 2>/dev/null || true
helm uninstall loki -n monitoring 2>/dev/null || true
helm uninstall promtail -n monitoring 2>/dev/null || true

kubectl delete pods --all -n monitoring --force --grace-period=0 2>/dev/null || true
kubectl delete pvc --all -n monitoring 2>/dev/null || true

echo "⏳ Waiting for cleanup..."
sleep 20

echo "📊 Installing Prometheus + Grafana..."
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values k8s/monitoring/prometheus-values-small.yaml \
  --timeout 10m

echo "⏳ Waiting for Prometheus..."
kubectl wait --for=condition=ready pod -n monitoring -l app.kubernetes.io/name=prometheus --timeout=300s

echo "📝 Installing Loki..."
helm install loki grafana/loki \
  --namespace monitoring \
  --values k8s/monitoring/loki-values.yaml \
  --timeout 10m

echo "⏳ Waiting for Loki..."
sleep 30

echo "📋 Installing Promtail..."
helm install promtail grafana/promtail \
  --namespace monitoring \
  --values k8s/monitoring/promtail-values.yaml

echo "⏳ Waiting for Promtail..."
sleep 20

echo "🔗 Configuring Loki in Grafana..."
kubectl apply -f k8s/monitoring/grafana-loki-datasource.yaml

echo "🔄 Restarting Grafana..."
kubectl rollout restart deployment -n monitoring prometheus-grafana

echo "⏳ Waiting for Grafana..."
kubectl wait --for=condition=ready pod -n monitoring -l app.kubernetes.io/name=grafana --timeout=180s

echo ""
echo "✅ Monitoring stack installed successfully!"
echo ""
echo "📊 Check status:"
echo "   kubectl get pods -n monitoring"
echo ""
echo "🌐 Access Grafana:"
echo "   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "   Then open: http://localhost:3000"
echo "   Login: admin / admin123"
echo ""