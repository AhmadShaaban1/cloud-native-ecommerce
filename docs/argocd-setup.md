# 🔄 ArgoCD GitOps Setup Guide

## Overview

ArgoCD enables GitOps - declarative, version-controlled infrastructure and application deployment.

## Architecture
```
GitHub Repository
      ↓
ArgoCD Monitors Changes
      ↓
Auto-Sync to Kubernetes
      ↓
Application Running
```

## Installation

### Quick Install
```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
```

### Get Admin Password
```bash
# Get initial password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Save this password!
```

### Access ArgoCD UI
```bash
# Port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Open: https://localhost:8080
# Username: admin
# Password: (from above)
```

## Configure Application

### Create Application via UI

1. Go to ArgoCD UI
2. Click **+ NEW APP**
3. Fill in:
   - **Application Name**: ecommerce-app
   - **Project**: default
   - **Sync Policy**: Automatic
   - **Repository URL**: https://github.com/AhmadShaaban1/cloud-native-ecommerce.git
   - **Revision**: HEAD
   - **Path**: k8s/base/deployments
   - **Cluster**: https://kubernetes.default.svc
   - **Namespace**: default
4. Click **CREATE**

### Create Application via YAML
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ecommerce-app
  namespace: argocd
spec:
  project: default
  
  source:
    repoURL: https://github.com/AhmadShaaban1/cloud-native-ecommerce.git
    targetRevision: HEAD
    path: k8s/base/deployments
  
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=false
```

Apply:
```bash
kubectl apply -f k8s/argocd/application.yaml
```

## Features

### 1. Auto-Sync

Automatically deploys changes from Git:
```yaml
syncPolicy:
  automated:
    prune: true      # Delete resources removed from Git
    selfHeal: true   # Revert manual changes
```

### 2. Manual Sync

Sync manually via UI or CLI:
```bash
argocd app sync ecommerce-app
```

### 3. Rollback

Rollback to previous version:
```bash
argocd app rollback ecommerce-app
```

### 4. Health Checks

ArgoCD monitors application health automatically.

## Multi-Environment Setup

### Structure
```
k8s/
├── base/
│   └── deployments/
└── overlays/
    ├── dev/
    │   └── kustomization.yaml
    └── prod/
        └── kustomization.yaml
```

### Dev Application
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ecommerce-dev
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/AhmadShaaban1/cloud-native-ecommerce.git
    targetRevision: main
    path: k8s/overlays/dev
  destination:
    server: https://kubernetes.default.svc
    namespace: default
```

### Prod Application
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ecommerce-prod
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/AhmadShaaban1/cloud-native-ecommerce.git
    targetRevision: v1.0.0  # Use tags for prod
    path: k8s/overlays/prod
  destination:
    server: https://production-cluster
    namespace: production
```

## CI/CD Integration

### GitHub Actions + ArgoCD
```yaml
# .github/workflows/deploy.yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  update-manifests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Update image tag
        run: |
          sed -i "s|image:.*user-service:.*|image: $ECR_REGISTRY/user-service:$GITHUB_SHA|" k8s/base/deployments/user-service.yaml
      
      - name: Commit changes
        run: |
          git config user.name github-actions
          git config user.email github-actions@github.com
          git add .
          git commit -m "Update image to $GITHUB_SHA"
          git push
```

ArgoCD will automatically detect and deploy changes.

## Operations

### View Sync Status
```bash
argocd app get ecommerce-app
```

### View Logs
```bash
argocd app logs ecommerce-app
```

### Force Sync
```bash
argocd app sync ecommerce-app --force
```

### Diff
```bash
argocd app diff ecommerce-app
```

## Best Practices

✅ Use Git tags for production deployments
✅ Enable auto-sync for dev, manual for prod
✅ Use Kustomize or Helm for multi-environment configs
✅ Implement proper RBAC in ArgoCD
✅ Monitor sync status via Prometheus
✅ Use ArgoCD notifications for alerts
✅ Keep secrets in Vault, not Git
✅ Use ArgoCD projects for team isolation

## Troubleshooting

### App Out of Sync

**Symptom**: Application shows "OutOfSync"

**Solution**:
```bash
# Check diff
argocd app diff ecommerce-app

# Sync
argocd app sync ecommerce-app
```

### Sync Failed

**Symptom**: Sync operation failed

**Solution**:
```bash
# View details
argocd app get ecommerce-app

# Check logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

### Manual Changes Reverted

**Symptom**: Manual kubectl changes are reverted

**Solution**: This is expected with `selfHeal: true`. Make changes in Git instead.

## References

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [GitOps Best Practices](https://argoproj.github.io/argo-cd/user-guide/best_practices/)