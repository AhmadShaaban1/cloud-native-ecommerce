#!/bin/bash

set -e

echo "📊 Installing Loki..."
helm install loki grafana/loki \
  --namespace monitoring \
  --values k8s/monitoring/loki-values.yaml

echo "⏳ Waiting for Loki to be ready..."
kubectl wait --for=condition=ready pod -n monitoring -l app.kubernetes.io/name=loki --timeout=120s

echo "📝 Installing Promtail..."
helm install promtail grafana/promtail \
  --namespace monitoring \
  --values k8s/monitoring/promtail-values.yaml

echo "⏳ Waiting for Promtail to be ready..."
sleep 10

echo "🔗 Adding Loki datasource to Grafana..."
kubectl apply -f k8s/monitoring/grafana-loki-datasource.yaml

echo "🔄 Restarting Grafana..."
kubectl rollout restart deployment -n monitoring prometheus-grafana

echo "⏳ Waiting for Grafana to be ready..."
kubectl wait --for=condition=ready pod -n monitoring -l app.kubernetes.io/name=grafana --timeout=120s

echo ""
echo "✅ Loki stack installed successfully!"
echo ""
echo "📊 Access Grafana:"
echo "   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo ""
echo "🔍 Check logs in Grafana Explore with query: {namespace=\"default\"}"