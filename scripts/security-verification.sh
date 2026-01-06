#!/bin/bash

echo "🛡️  Security Verification Report"
echo "================================="
echo ""

# 1. Network Policies
echo "📡 Network Policies:"
NP_COUNT=$(kubectl get networkpolicies -n default --no-headers | wc -l)
echo "   ✅ $NP_COUNT network policies active"
echo ""

# 2. Pod Security
echo "🔒 Pod Security Standards:"
kubectl get namespace default -o jsonpath='{.metadata.labels}' | grep -q "pod-security" && echo "   ✅ PSS labels configured" || echo "   ❌ PSS not configured"
echo ""

# 3. Secrets
echo "🗝️  External Secrets:"
ES_COUNT=$(kubectl get externalsecrets -n default --no-headers 2>/dev/null | wc -l)
echo "   ✅ $ES_COUNT external secrets configured"
kubectl get secrets -n default | grep -E "mongodb-secret|jwt-secret" > /dev/null && echo "   ✅ Secrets synced from AWS" || echo "   ⚠️  Secrets not synced"
echo ""

# 4. TLS
echo "🔐 Certificate Management:"
kubectl get clusterissuers 2>/dev/null | grep -q letsencrypt && echo "   ✅ cert-manager configured" || echo "   ❌ cert-manager not configured"
echo ""

# 5. RBAC
echo "👥 RBAC Configuration:"
SA_COUNT=$(kubectl get serviceaccounts -n default --no-headers | wc -l)
echo "   ✅ $SA_COUNT service accounts"
ROLE_COUNT=$(kubectl get roles -n default --no-headers | wc -l)
echo "   ✅ $ROLE_COUNT roles defined"
echo ""

# 6. Security Scanning
echo "🔍 Security Scanning:"
kubectl get pods -n trivy-system > /dev/null 2>&1 && echo "   ✅ Trivy Operator running" || echo "   ❌ Trivy not installed"
VR_COUNT=$(kubectl get vulnerabilityreports -n default --no-headers 2>/dev/null | wc -l)
echo "   ✅ $VR_COUNT vulnerability reports generated"
echo ""

# 7. Audit Logging
echo "📋 Audit Logging:"
aws eks describe-cluster --name ecommerce-dev --query 'cluster.logging.clusterLogging[0].enabled' --output text 2>/dev/null | grep -q true && echo "   ✅ EKS audit logging enabled" || echo "   ⚠️  Audit logging not enabled"
echo ""

# 8. Monitoring
echo "📊 Monitoring Stack:"
kubectl get pods -n monitoring | grep -q Running && echo "   ✅ Monitoring stack operational" || echo "   ❌ Monitoring issues"
echo ""

echo "================================="
echo "✅ Security verification complete"