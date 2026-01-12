# ☁️ Cloud-Native E-Commerce Platform

A **production-grade microservices architecture** deployed on **AWS EKS** with complete CI/CD, observability, and security hardening.

![Project Status](https://img.shields.io/badge/Status-Production%20Ready-success)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.33-blue)
![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple)
![AWS](https://img.shields.io/badge/AWS-EKS-orange)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 🏗️ Architecture Overview

### High-Level Architecture

┌─────────────────────────────────────────────────────────────┐
│ AWS Cloud │
│ ┌───────────────────────────────────────────────────────┐ │
│ │ VPC (10.0.0.0/16) │ │
│ │ │ │
│ │ ┌──────────────┐ ┌──────────────┐ │ │
│ │ │ Public │ │ Private │ │ │
│ │ │ Subnets │ │ Subnets │ │ │
│ │ │ │ │ │ │ │
│ │ │ ┌────────┐ │ │ ┌────────┐ │ │ │
│ │ │ │ ALB │ │ │ │ EKS │ │ │ │
│ │ │ │ │ │ │ │ Nodes │ │ │ │
│ │ │ └────────┘ │ │ └────────┘ │ │ │
│ │ │ │ │ │ │ │
│ │ │ ┌────────┐ │ │ ┌────────┐ │ │ │
│ │ │ │ NAT │ │──────────────▶ │ Pods │ │ │ │
│ │ │ │Gateway │ │ │ │ │ │ │ │
│ │ │ └────────┘ │ │ └────────┘ │ │ │
│ │ └──────────────┘ └──────────────┘ │ │
│ │ │ │
│ └───────────────────────────────────────────────────────┘ │
│ │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│ │ RDS │ │ Redis │ │ ECR │ │
│ │ (Future) │ │ (Future) │ │ │ │
│ └──────────┘ └──────────┘ └──────────┘ │
└─────────────────────────────────────────────────────────────┘


---

## 🧰 Technology Stack

### Infrastructure
- ☁️ AWS EKS – Managed Kubernetes (v1.30)
- 🏗️ Terraform – Infrastructure as Code
- 🌐 VPC – Public & Private subnets
- 🔐 IAM – Role-based access control (IRSA)

### Backend
- 🟢 Node.js – Microservices runtime
- 🐳 Docker – Containerization
- ☸️ Kubernetes – Orchestration

### Coming Soon
- 📊 Prometheus & Grafana – Monitoring
- 📝 ELK Stack – Logging
- 🔄 GitHub Actions – CI/CD

---

## 📁 Project Structure

cloud-native-ecommerce/
├── services/
│ ├── user-service/
│ ├── product-service/
│ ├── order-service/
│ └── payment-service/
│
├── frontend/ # React (Coming Soon)
├── docker/
│ └── docker-compose.yml
├── k8s/
│ ├── base/
│ └── overlays/
├── terraform/
│ ├── modules/
│ │ ├── vpc/
│ │ ├── eks/
│ │ └── security/
│ └── environments/
│ ├── dev/
│ └── prod/
├── .github/workflows/
├── docs/
│ └── docker-guide.md
└── scripts/
└── push-to-ecr.sh

## 🚀 Implementation Status

### ✅ Phase 0 – Planning & AWS Foundation
- AWS account & CLI configured
- IAM user & local tooling ready

### ✅ Phase 1 – Application Setup
- Repo & structure created
- 4 microservices bootstrapped
- Health endpoints added

### ✅ Phase 2 – Containerization
- Multi-stage Dockerfiles
- Docker Compose (local)
- Images pushed to ECR

### ✅ Phase 3 – EKS with Terraform
- VPC with public/private subnets
- NAT Gateway
- EKS Cluster (v1.30)
- Node Group (2 × t3.small)
- OIDC + IRSA enabled

### 🔄 Phase 4 – Kubernetes Deployments
- Deployments & Services
- ConfigMaps & Secrets
- Ingress Controller

### 📅 Phase 5 – CI/CD
- GitHub Actions & Jenkins
- Automated build & deploy

### ✅ Phase 6: Observability (Complete)
- [x] Prometheus for metrics collection
- [x] Grafana for visualization
- [x] Loki for log aggregation
- [x] Promtail for log collection
- [x] Node Exporter for infrastructure metrics
- [x] Kube State Metrics for cluster metrics
- [x] Custom dashboards configured
- [x] All running on 4-node cluster

### 🔄 Phase 7: Security & Production Hardening (Next)
- [ ] Network policies
- [ ] Pod security standards
- [ ] Secrets management
- [ ] SSL/TLS certificates
- [ ] RBAC fine-tuning
- [ ] Security scanning
---

## 🛠️ Getting Started

### Prerequisites
- AWS Account
- Terraform ≥ 1.0
- kubectl ≥ 1.28
- Docker ≥ 20.x
- Node.js ≥ 18.x

### Local Development

```bash
git clone https://github.com/AhmadShaaban1/cloud-native-ecommerce.git
cd cloud-native-ecommerce
docker-compose up -d

# Test services
curl http://localhost:3001/health  # User
curl http://localhost:3002/health  # Product
curl http://localhost:3003/health  # Order
curl http://localhost:3004/health  # Payment
```

### Deploy to AWS EKS

#### 1. Infrastructure Setup
```bash
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Plan infrastructure
terraform plan

# Apply infrastructure (takes 15-20 minutes)
terraform apply

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name ecommerce-dev
```

#### 2. Deploy Applications
```bash
# Build and push images
./scripts/build-and-push.sh

# Deploy to Kubernetes
kubectl apply -f k8s/base/deployments/
kubectl apply -f k8s/ingress/

# Verify deployment
kubectl get pods
kubectl get ingress
```

#### 3. Install Monitoring
```bash
./scripts/install-monitoring-final.sh

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Visit http://localhost:3000 (admin/admin123)
```

#### 4. Apply Security Configurations
```bash
./scripts/security-setup.sh

# Verify
./scripts/security-verification.sh
```

---

## 🔄 Recovery After Terraform Destroy

See detailed guide: [docs/recovery-workflow.md](docs/recovery-workflow.md)

**Quick Recovery:**
```bash
# 1. Recreate infrastructure
cd terraform/environments/dev
terraform apply

# 2. Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name ecommerce-dev

# 3. Run recovery script
./scripts/recovery-after-destroy.sh

# Takes ~30-40 minutes total
```

---

## 🏭 Production Environment

Production environment configured with:
- **6-12 nodes** (auto-scaling)
- **t3.medium instances** (vs t3.small in dev)
- **3 availability zones** (vs 2 in dev)
- **Multi-AZ NAT gateways** (HA)
- **Stricter resource limits**
- **30-day log retention**
- **Blue/Green deployments**

See comparison: [docs/dev-vs-prod.md](docs/dev-vs-prod.md)

**To deploy production:**
```bash
cd terraform/environments/prod
terraform init
terraform apply
```

---

## 📊 Resources & Costs

### Development Environment (8 nodes)
| Component | Configuration | Monthly Cost |
|-----------|---------------|--------------|
| EKS Control Plane | 1 cluster | $73 |
| EC2 Nodes | 8x t3.small | $240 |
| NAT Gateway | 1 gateway | $32 |
| EBS Storage | ~30GB | $3 |
| Data Transfer | Variable | ~$10 |
| **Total** | | **~$358/month** |

### Production Environment (6-12 nodes)
| Component | Configuration | Monthly Cost |
|-----------|---------------|--------------|
| EKS Control Plane | 1 cluster | $73 |
| EC2 Nodes | 6x t3.medium | $240 |
| NAT Gateways | 3 gateways (HA) | $96 |
| Load Balancers | 2 ALBs | $40 |
| EBS Storage | ~50GB | $5 |
| Backups | Daily snapshots | $50 |
| Data Transfer | Variable | ~$20 |
| **Total** | | **~$524/month** |

**Cost Optimization Tips:**
- Use `terraform destroy` when not in use
- Scale nodes to 0 during off-hours
- Use spot instances (70% savings)
- Set up auto-shutdown schedules

---

## 🔍 Monitoring & Observability

### Access Dashboards
```bash
# Grafana (Metrics & Logs)
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# http://localhost:3000 (admin/admin123)

# Prometheus (Raw Metrics)
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# http://localhost:9090

# Loki (Log Queries)
kubectl port-forward -n monitoring svc/loki-gateway 3100:80
# http://localhost:3100
```

### Key Metrics

**Application Metrics:**
- HTTP request rate: `rate(http_requests_total[5m])`
- 95th percentile latency: `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))`