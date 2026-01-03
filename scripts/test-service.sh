#!/bin/bash

# Get ALB URL
ALB_URL=$(kubectl get ingress ecommerce-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$ALB_URL" ]; then
    echo "❌ ALB not ready yet. Wait a few minutes and try again."
    exit 1
fi

echo "🌐 Testing services at: http://$ALB_URL"
echo ""

echo "🔵 Testing User Service..."
curl -s http://$ALB_URL/api/users | jq '.' || echo "Failed"
echo ""

echo "🟢 Testing Product Service..."
curl -s http://$ALB_URL/api/products | jq '.' || echo "Failed"
echo ""

echo "🟡 Testing Order Service..."
curl -s http://$ALB_URL/api/orders | jq '.' || echo "Failed"
echo ""

echo "🟠 Testing Payment Service..."
curl -s http://$ALB_URL/api/payments | jq '.' || echo "Failed"
echo ""

echo "✅ All services tested!"
echo ""
echo "📍 Your public endpoint: http://$ALB_URL"