# ☸️ Kubernetes Deployment Guide

## Current Deployment

### Pods Running
- **MongoDB**: 1 pod (database)
- **Redis**: 1 pod (cache)
- **User Service**: 2 pods (port 3001)
- **Product Service**: 2 pods (port 3002)
- **Order Service**: 2 pods (port 3003)
- **Payment Service**: 2 pods (port 3004)

**Total: 10 pods**

### Services
All services are exposed via ClusterIP internally and routed through AWS ALB externally.

### Ingress
- **Type**: AWS Application Load Balancer (ALB)
- **Routes**:
  - `/api/users` → User Service
  - `/api/products` → Product Service
  - `/api/orders` → Order Service
  - `/api/payments` → Payment Service

## Useful Commands
```bash
# View all pods
kubectl get pods

# View services
kubectl get svc

# View ingress
kubectl get ingress

# Get ALB URL
kubectl get ingress ecommerce-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# View logs
kubectl logs -l app=user-service --tail=50

# Port-forward for testing
kubectl port-forward svc/user-service 3001:3001

# Restart a deployment
kubectl rollout restart deployment user-service

# Scale a deployment
kubectl scale deployment user-service --replicas=3
```

## Health Checks

All services implement health endpoints at `/health`.

## Resources

Each service is configured with:
- **Requests**: 128Mi RAM, 100m CPU
- **Limits**: 256Mi RAM, 200m CPU