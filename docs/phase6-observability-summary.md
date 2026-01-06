# Phase 6: Observability - Summary

## ✅ Completed Tasks

### Infrastructure
- **Cluster**: 4x t3.small nodes (scaled from 2)
- **Kubernetes Version**: 1.33
- **Storage**: EBS CSI Driver with gp3 volumes
- **Namespace**: Dedicated `monitoring` namespace

### Monitoring Stack Deployed

#### Prometheus Stack
- **Prometheus Server**: Metrics collection with 7-day retention
- **Grafana**: Visualization dashboard (admin/admin123)
- **Kube State Metrics**: Cluster state metrics
- **Node Exporter**: 4 DaemonSet pods (one per node)
- **Prometheus Operator**: CRD management

#### Logging Stack
- **Loki**: Log aggregation (SingleBinary mode)
- **Loki Gateway**: API gateway for log queries
- **Promtail**: 4 DaemonSet pods for log collection

## 📊 Resources Created

| Component | Replicas | CPU Request | Memory Request | Storage |
|-----------|----------|-------------|----------------|---------|
| Prometheus | 1 | 150m | 512Mi | 10Gi EBS |
| Grafana | 1 | 100m | 256Mi | 5Gi EBS |
| Loki | 1 | 100m | 256Mi | 10Gi EBS |
| Loki Gateway | 1 | 50m | 100Mi | - |
| Kube State Metrics | 1 | 20m | 50Mi | - |
| Node Exporter | 4 | 20m | 50Mi | - |
| Promtail | 4 | 25m | 64Mi | - |

**Total Resources:**
- CPU Requests: ~600m
- Memory Requests: ~2Gi
- Storage: 25Gi EBS

## 🔗 Access URLs
```bash
# Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# http://localhost:3000

# Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# http://localhost:9090

# Loki Gateway
kubectl port-forward -n monitoring svc/loki-gateway 3100:80
# http://localhost:3100
```

## 📈 Key Metrics Available

### Application Metrics
- HTTP request rate
- Request duration (latency)
- Error rates
- Custom business metrics

### Infrastructure Metrics
- Node CPU/Memory/Disk usage
- Pod resource consumption
- Container restart counts
- Network traffic

### Logs
- All pod logs aggregated in Loki
- Queryable by namespace, pod, container
- Retention: 30 days

## 🎨 Grafana Dashboards

Pre-installed dashboards:
1. **Kubernetes Cluster Overview** - Cluster health
2. **Node Exporter Full** - Node-level metrics
3. **Prometheus Stats** - Prometheus performance
4. **Loki Logs** - Log exploration

## 🔍 Sample Queries

### PromQL (Prometheus)
```promql
# HTTP request rate per service
rate(http_requests_total[5m])

# 95th percentile latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Pod CPU usage
rate(container_cpu_usage_seconds_total{namespace="default"}[5m])
```

### LogQL (Loki)
```logql
# All logs from default namespace
{namespace="default"}

# Logs from user-service
{namespace="default", app="user-service"}

# Error logs
{namespace="default"} |= "error"
```

## 🐛 Issues Encountered & Resolved

### Issue 1: Loki Canary Pods
**Problem**: Loki deployed in distributed mode with canary pods
**Solution**: Forced SingleBinary deployment mode with explicit overrides

### Issue 2: Resource Constraints
**Problem**: Pods pending due to insufficient resources on 2 nodes
**Solution**: Scaled from 2 to 4 t3.small nodes

### Issue 3: Duplicate Grafana Deployments
**Problem**: Multiple Grafana deployments causing resource waste
**Solution**: Cleaned up duplicate deployments

### Issue 4: Loki Gateway URL
**Problem**: Incorrect Loki URL in Grafana datasource
**Solution**: Updated to `http://loki-gateway.monitoring.svc.cluster.local`

## 💰 Monthly Cost

| Component | Cost/Month |
|-----------|------------|
| EKS Control Plane | $73 |
| 4x t3.small nodes | $60 |
| NAT Gateway | $32 |
| EBS Storage (25Gi) | $2 |
| Data Transfer | ~$5 |
| **Total** | **~$172/month** |

## 🎯 Key Achievements

✅ Full observability stack operational
✅ Metrics + Logs in single platform (Grafana)
✅ Production-grade monitoring setup
✅ Scalable architecture (4 nodes)
✅ Persistent storage for data retention
✅ Resource-optimized deployments

## 📚 Configuration Files

- `k8s/monitoring/prometheus-optimized.yaml` - Prometheus values
- `k8s/monitoring/loki-minimal.yaml` - Loki values
- `k8s/monitoring/promtail-minimal.yaml` - Promtail values
- `k8s/storage/storage-class.yaml` - EBS StorageClass
- `scripts/install-monitoring-final.sh` - Installation script
- `scripts/fix-pending-pods.sh` - Fix script

## 🔜 Next Steps

**Phase 7: Security & Production Hardening**
- Implement network policies
- Configure pod security standards
- Integrate AWS Secrets Manager
- Add SSL/TLS with cert-manager
- Fine-tune RBAC
- Add security scanning with Trivy

---

**Last Updated**: January 4, 2026
**Status**: ✅ Production Ready