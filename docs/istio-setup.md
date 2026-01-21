# 🌐 Istio Service Mesh Setup Guide

## Overview

Istio provides:
- Traffic management
- Security (mTLS)
- Observability
- Resilience (circuit breakers, retries)

## Installation

### Quick Install
```bash
# Download Istio
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.20.1 sh -
cd istio-1.20.1
export PATH=$PWD/bin:$PATH

# Install with demo profile
istioctl install --set profile=demo -y

# Enable sidecar injection
kubectl label namespace default istio-injection=enabled
```

### Verify Installation
```bash
kubectl get pods -n istio-system

# Should see:
# - istiod (control plane)
# - istio-ingressgateway
# - istio-egressgateway
```

## Configuration

### Gateway (Ingress)
```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: ecommerce-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
```

### Virtual Service (Routing)
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: user-service
spec:
  hosts:
  - user-service
  http:
  - match:
    - uri:
        prefix: /api/users
    route:
    - destination:
        host: user-service
        port:
          number: 3001
```

### Destination Rule (Load Balancing)
```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: user-service
spec:
  host: user-service
  trafficPolicy:
    loadBalancer:
      simple: LEAST_REQUEST
```

## Features

### 1. Traffic Splitting (Canary Deployment)
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: user-service
spec:
  hosts:
  - user-service
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: user-service
        subset: v2
  - route:
    - destination:
        host: user-service
        subset: v1
      weight: 90
    - destination:
        host: user-service
        subset: v2
      weight: 10
```

### 2. Circuit Breaking
```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: payment-service
spec:
  host: payment-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 50
        maxRequestsPerConnection: 2
    outlierDetection:
      consecutive5xxErrors: 5
      interval: 30s
      baseEjectionTime: 30s
```

### 3. Retry Policy
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: order-service
spec:
  hosts:
  - order-service
  http:
  - route:
    - destination:
        host: order-service
    retries:
      attempts: 3
      perTryTimeout: 2s
      retryOn: 5xx,reset,connect-failure
```

### 4. Timeout
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: payment-service
spec:
  hosts:
  - payment-service
  http:
  - route:
    - destination:
        host: payment-service
    timeout: 10s
```

## Observability

### Kiali (Service Mesh Dashboard)
```bash
# Install
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/kiali.yaml

# Access
kubectl port-forward svc/kiali -n istio-system 20001:20001

# Open: http://localhost:20001
```

### Jaeger (Distributed Tracing)
```bash
# Install
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/jaeger.yaml

# Access
kubectl port-forward svc/jaeger-query -n istio-system 16686:16686

# Open: http://localhost:16686
```

### Grafana (Istio Metrics)
```bash
# Install
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/grafana.yaml

# Access
kubectl port-forward svc/grafana -n istio-system 3001:3000

# Open: http://localhost:3001
```

## Security (mTLS)

### Enable Strict mTLS
```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: default
spec:
  mtls:
    mode: STRICT
```

### Authorization Policy
```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-user-service
  namespace: default
spec:
  selector:
    matchLabels:
      app: user-service
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/frontend-sa"]
    to:
    - operation:
        methods: ["GET", "POST"]
```

## Troubleshooting

### Check Sidecar Injection
```bash
# Verify namespace label
kubectl get namespace default --show-labels

# Check if pod has sidecar
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].name}'
# Should show: <app-container> istio-proxy
```

### View Sidecar Logs
```bash
kubectl logs <pod-name> -c istio-proxy
```

### Check Istio Configuration
```bash
# Analyze namespace
istioctl analyze -n default

# Check proxy config
istioctl proxy-config routes <pod-name>
```

## Best Practices

✅ Always enable sidecar injection for application namespaces
✅ Use Virtual Services for traffic management
✅ Implement circuit breakers for external services
✅ Enable mTLS for service-to-service communication
✅ Use Kiali for visualizing service mesh
✅ Monitor with Grafana dashboards
✅ Implement retry and timeout policies
✅ Use authorization policies for security

## Performance Tips

- Use `LEAST_REQUEST` load balancing for better distribution
- Set appropriate connection pool limits
- Configure outlier detection to remove unhealthy instances
- Use HTTP/2 where possible
- Monitor latency with Jaeger

## References

- [Istio Documentation](https://istio.io/latest/docs/)
- [Traffic Management](https://istio.io/latest/docs/tasks/traffic-management/)
- [Security](https://istio.io/latest/docs/tasks/security/)
- [Observability](https://istio.io/latest/docs/tasks/observability/)