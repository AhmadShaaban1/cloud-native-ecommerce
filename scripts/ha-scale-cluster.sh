#!/bin/bash

set -e

echo "=========================================="
echo "🚀 High Availability Cluster Scaling"
echo "=========================================="
echo ""

# Current status
echo "📊 Current cluster status:"
kubectl get nodes
echo ""
kubectl top nodes
echo ""

# Pod distribution
echo "📦 Current pod distribution per node:"
kubectl get pods --all-namespaces -o wide | awk '{print $8}' | sort | uniq -c
echo ""

# Confirmation
read -p "Scale cluster from 4 to 6 nodes? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Scaling cancelled"
    exit 1
fi

echo ""
echo "📝 Updating Terraform configuration..."

cd terraform/environments/dev

# Backup current state
terraform state pull > backup-state-before-scaling-$(date +%Y%m%d-%H%M%S).json

echo "✅ State backed up"

# Show plan
echo ""
echo "📋 Terraform plan:"
terraform plan -out=scale.tfplan

echo ""
read -p "Apply the plan? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Scaling cancelled"
    exit 1
fi

# Apply
echo ""
echo "⚡ Scaling cluster (this takes 5-7 minutes)..."
terraform apply scale.tfplan

echo ""
echo "⏳ Waiting for new nodes to be ready..."
sleep 60

# Verify
echo ""
echo "=========================================="
echo "✅ Scaling Complete!"
echo "=========================================="
echo ""

echo "📊 New cluster status:"
kubectl get nodes
echo ""

echo "📦 New pod distribution:"
kubectl get pods --all-namespaces -o wide | awk '{print $8}' | sort | uniq -c
echo ""

echo "💡 Tips:"
echo "   - Pods will automatically rebalance"
echo "   - You can now deploy more applications"
echo "   - Monitor with: kubectl top nodes"
echo ""