# ☁️ Cloud-Native E-Commerce Platform

A **production-grade microservices platform** on **AWS EKS** featuring complete observability, enterprise security, and automated CI/CD pipelines.

![Status](https://img.shields.io/badge/Status-Production%20Ready-success)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.33-blue)
![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple)
![AWS](https://img.shields.io/badge/AWS-EKS-orange)

---

## 🎯 Project Overview

This project demonstrates **production-level DevOps practices** with a fully functional e-commerce platform running on Kubernetes. Built from scratch with real-world troubleshooting and optimization.

### Key Features
- 🚀 **Multi-node EKS clusters** (8 dev / 12 prod nodes)
- 🔄 **Automated CI/CD** with GitHub Actions
- 📊 **Full observability** - Prometheus, Grafana, Loki
- 🔐 **Enterprise security** - Network policies, RBAC, secrets management
- 🏗️ **100% Infrastructure as Code** with Terraform.
- 🐳 **Optimized containers** with multi-stage Docker builds
- ☸️ **Kubernetes-native** deployments with health checks

---

## 🏗️ Architecture
```
Internet → AWS ALB → Kubernetes Ingress
                          ↓
        ┌─────────────────┼─────────────────┐
        ↓                 ↓                 ↓
   User Service    Product Service    Order Service → Payment Service
        ↓                 ↓                 ↓
        └─────────────────┼─────────────────┘
                          ↓
                   MongoDB + Redis
```

### Infrastructure Components
- **AWS EKS**: Managed Kubernetes (v1.33)
- **VPC**: Custom networking with public/private subnets
- **Nodes**: 8 t3.small (dev) / 12 t3.small (prod)
- **Storage**: EBS CSI Driver with gp3 volumes
- **Load Balancing**: Application Load Balancer
- **Container Registry**: Amazon ECR

---

## 📁 Project Structure
```
cloud-native-ecommerce/
├── services/                    # 4 Microservices (Node.js)
│   ├── user-service/           # Authentication & users
│   ├── product-service/        # Product catalog
│   ├── order-service/          # Order management
│   └── payment-service/        # Payment processing
├── k8s/                        # Kubernetes manifests
│   ├── base/deployments/       # Service deployments
│   ├── ingress/                # ALB ingress
│   ├── monitoring/             # Observability stack
│   ├── security/               # Network policies, RBAC
│   └── storage/                # StorageClass configs
├── terraform/                  # Infrastructure as Code
│   ├── modules/                # Reusable modules
│   └── environments/
│       ├── dev/                # 8 nodes
│       └── prod/               # 12 nodes
├── .github/workflows/          # CI/CD pipelines
├── docs/                       # Comprehensive docs
└── scripts/                    # Automation scripts
```

---

## 🚀 Technology Stack

| Layer | Technologies |
|-------|-------------|
| **Cloud** | AWS (EKS, VPC, IAM, ECR, EBS, Secrets Manager) |
| **Container Orchestration** | Kubernetes 1.33 |
| **Infrastructure as Code** | Terraform 1.0+ |
| **Backend** | Node.js 18, Express.js |
| **Databases** | MongoDB 7.0, Redis 7.2 |
| **CI/CD** | GitHub Actions |
| **Monitoring** | Prometheus, Grafana, Loki, Promtail |
| **Security** | Network Policies, RBAC, External Secrets, Trivy |
| **Containerization** | Docker (multi-stage builds) |

---

## 📊 Implementation Phases

### ✅ Phase 0-7 (Complete)
- [x] **Phase 0**: AWS Foundation
- [x] **Phase 1**: Project Structure & Repository
- [x] **Phase 2**: Docker Containerization
- [x] **Phase 3**: EKS Cluster with Terraform
- [x] **Phase 4**: Kubernetes Deployments
- [x] **Phase 5**: CI/CD Pipeline
- [x] **Phase 6**: Observability Stack
- [x] **Phase 7**: Security Hardening

### 🔄 Phase 8 (In Progress)
- [ ] Service Mesh (Istio)
- [ ] GitOps with ArgoCD
- [ ] HashiCorp Vault integration
- [ ] Frontend application (React)

---

## 💻 Quick Start

### Prerequisites
```bash
# Required tools
- AWS CLI (configured)
- kubectl >= 1.28
- Terraform >= 1.0
- Docker >= 20.x
- Helm >= 3.x
- Node.js >= 18.x
```

### Local Development
```bash
# Clone repository
git clone https://github.com/AhmadShaaban1/cloud-native-ecommerce.git
cd cloud-native-ecommerce

# Run locally with Docker Compose
docker-compose up -d

# Test services
curl http://localhost:3001/health  # User service
curl http://localhost:3002/health  # Product service
curl http://localhost:3003/health  # Order service
curl http://localhost:3004/health  # Payment service
```

### Deploy to AWS

#### 1. Infrastructure
```bash
cd terraform/environments/dev
terraform init
terraform apply  # ~20 minutes

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name ecommerce-dev
```

#### 2. Applications
```bash
# Build and push to ECR
./scripts/build-and-push.sh

# Deploy to Kubernetes
kubectl apply -f k8s/base/deployments/
kubectl apply -f k8s/ingress/
```

#### 3. Monitoring
```bash
./scripts/install-monitoring-final.sh

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# http://localhost:3000 (admin/admin123)
```

#### 4. Security
```bash
kubectl apply -f k8s/security/
./scripts/security-verification.sh
```

---

## 🌍 Environments

### Development (8 nodes)
- **Instance Type**: t3.small
- **Nodes**: 8 (min: 6, max: 10)
- **VPC CIDR**: 10.0.0.0/16
- **AZs**: 2
- **NAT**: 1 gateway
- **Cost**: ~$240/month

### Production (12 nodes)
- **Instance Type**: t3.small
- **Nodes**: 12 (min: 10, max: 15)
- **VPC CIDR**: 10.1.0.0/16
- **AZs**: 3
- **NAT**: 3 gateways (HA)
- **Cost**: ~$360/month

---

## 📊 Observability

### Grafana Dashboards
```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Default credentials: admin / admin123
```

**Pre-configured dashboards:**
- Kubernetes cluster overview
- Node metrics
- Pod resource usage
- Application performance
- Log exploration

### Key Metrics
```promql
# Request rate
rate(http_requests_total[5m])

# P95 latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Error rate
rate(http_requests_total{status_code=~"5.."}[5m])
```

### Log Queries (Loki)
```logql
# All application logs
{namespace="default"}

# Specific service
{app="user-service"}

# Error logs
{namespace="default"} |= "error"
```

---

## 🔐 Security Features

✅ **Network Security**
- Default deny-all network policies
- Service-to-service communication rules
- Controlled egress to internet

✅ **Pod Security**
- Pod Security Standards enforced
- Non-root containers
- Read-only root filesystem
- Dropped capabilities

✅ **Secrets Management**
- AWS Secrets Manager integration
- External Secrets Operator
- Automatic rotation (1h)
- Zero hardcoded secrets

✅ **Access Control**
- RBAC with least privilege
- Service accounts per service
- IAM roles for service accounts (IRSA)

✅ **TLS/SSL**
- cert-manager for automation
- Let's Encrypt integration

✅ **Security Scanning**
- Trivy Operator (continuous)
- Vulnerability reports
- Configuration audits

✅ **Audit**
- EKS audit logs enabled
- CloudWatch integration

---

## 🐛 Troubleshooting

### Common Issues

**Pods Pending:**
```bash
kubectl describe pod <pod-name>
kubectl top nodes
# Solution: Scale node group or reduce resource requests
```

**Can't Access Service:**
```bash
kubectl get ingress
kubectl get svc
kubectl logs -l app=<service-name>
```

**After Terraform Destroy:**
```bash
# Follow recovery workflow
./scripts/recovery-after-destroy.sh
# See docs/recovery-workflow.md
```

---

## 📚 Documentation

- [Recovery Workflow](docs/recovery-workflow.md)
- [Dev vs Prod Environments](docs/dev-vs-prod.md)
- [Troubleshooting Showcase](docs/troubleshooting-showcase.md)
- [Security Checklist](docs/security-checklist.md)
- [Phase Summaries](docs/)

---

## 🎯 Real-World Challenges Solved

### 1. Terraform State Recovery
**Challenge**: Accidentally deleted main.tf
**Solution**: Used Git history to recover configuration
**Skills**: Git mastery, Terraform state management

### 2. Node Capacity Planning
**Challenge**: Pods pending due to insufficient resources
**Solution**: Scaled from 4 → 8 nodes in dev, 12 in prod
**Skills**: Kubernetes resource management, capacity planning

### 3. Loki Deployment Issues
**Challenge**: Unwanted distributed mode components
**Solution**: Explicit Helm overrides for SingleBinary mode
**Skills**: Helm chart customization, debugging

### 4. Cost Optimization
**Challenge**: High AWS costs
**Solution**: t3.small nodes, right-sized resources, terraform destroy workflow
**Skills**: Cloud cost management, resource optimization

---

## 💰 Cost Breakdown

### Development (8 nodes)
| Component | Cost/Month |
|-----------|------------|
| EKS Control Plane | $73 |
| 8x t3.small nodes | $240 |
| NAT Gateway | $32 |
| EBS Storage | $3 |
| Data Transfer | $10 |
| **Total** | **~$358** |

### Production (12 nodes)
| Component | Cost/Month |
|-----------|------------|
| EKS Control Plane | $73 |
| 12x t3.small nodes | $360 |
| 3x NAT Gateways | $96 |
| EBS Storage | $5 |
| Load Balancers | $40 |
| Data Transfer | $15 |
| **Total** | **~$589** |

**Cost Optimization:**
- Use `terraform destroy` when not in use
- Set up auto-shutdown schedules
- Consider spot instances (70% savings)

---

## 🚀 Future Enhancements

- [ ] Service Mesh (Istio/Linkerd)
- [ ] GitOps with ArgoCD
- [ ] HashiCorp Vault for secrets
- [ ] React frontend application
- [ ] GraphQL API gateway
- [ ] Advanced monitoring (APM)
- [ ] Chaos Engineering
- [ ] Multi-region deployment

---

## 🤝 Contributing

This is a learning/portfolio project. Feedback welcome!

---

## 👨‍💻 Author

**Ahmed Shaaban**
- GitHub: [@AhmadShaaban1](https://github.com/AhmadShaaban1)
- Portfolio: [cloud-native-ecommerce](https://github.com/AhmadShaaban1/cloud-native-ecommerce)

---

## 🎓 Skills Demonstrated

**Technical:**
✅ AWS (EKS, VPC, IAM, Secrets Manager, ECR)
✅ Kubernetes (Deployments, Services, Ingress, Network Policies)
✅ Terraform (IaC, Modules, State Management)
✅ Docker (Multi-stage builds, Optimization)
✅ CI/CD (GitHub Actions, Automated Pipelines)
✅ Monitoring (Prometheus, Grafana, Loki)
✅ Security (RBAC, Network Policies, Secret Management)
✅ Git (Version Control, Recovery, Branching)

**DevOps Practices:**
✅ Infrastructure as Code
✅ GitOps principles
✅ Container orchestration
✅ Microservices architecture
✅ Security-first approach
✅ Observability
✅ Incident response
✅ Documentation

**Soft Skills:**
✅ Problem-solving under pressure
✅ Systematic debugging
✅ Learning from failures
✅ Self-directed learning
✅ Technical documentation

---

## 📝 License

MIT License

---

**Status**: Production Ready | **Nodes**: 8 (dev) / 12 (prod) | **Version**: 1.0.0

Last Updated: January 31, 2026
