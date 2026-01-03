#!/bin/bash

set -e

echo "🧹 Cleaning up existing installation..."
helm uninstall prometheus -n monitoring 2>/dev/null || true
kubectl delete namespace monitoring 2>/dev/null || true

echo "⏳ Waiting for namespace to be deleted..."
sleep 10

echo "📦 Creating monitoring namespace..."
kubectl create namespace monitoring

echo "🔍 Verifying EBS CSI driver..."
kubectl wait --for=condition=ready pod -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver --timeout=60s

echo "💾 Verifying StorageClass..."
kubectl get storageclass ebs-sc || kubectl apply -f k8s/storage/storage-class.yaml

echo "📊 Installing Prometheus stack..."
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values k8s/monitoring/prometheus-values.yaml \
  --set prometheusOperator.admissionWebhooks.enabled=false \
  --timeout 10m

echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -n monitoring -l app.kubernetes.io/name=kube-state-metrics --timeout=300s

echo "✅ Monitoring stack installed successfully!"
echo ""
echo "📊 Check status with: kubectl get pods -n monitoring"
echo "🌐 Access Grafana: kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"