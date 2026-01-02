# ☁️ Cloud-Native E-Commerce Platform

A production-grade microservices architecture deployed on **AWS EKS** using modern DevOps practices.

![Project Status](https://img.shields.io/badge/Status-In%20Development-yellow)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.30-blue)
![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple)
![AWS](https://img.shields.io/badge/AWS-EKS-orange)

---

## 🏗️ Architecture Overview

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                        AWS Cloud                            │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                    VPC (10.0.0.0/16)                  │  │
│  │                                                       │  │
│  │  ┌──────────────┐              ┌──────────────┐     │  │
│  │  │   Public     │              │   Private    │     │  │
│  │  │   Subnets    │              │   Subnets    │     │  │
│  │  │              │              │              │     │  │
│  │  │  ┌────────┐  │              │  ┌────────┐  │     │  │
│  │  │  │  ALB   │  │              │  │  EKS   │  │     │  │
│  │  │  │        │  │              │  │  Nodes │  │     │  │
│  │  │  └────────┘  │              │  └────────┘  │     │  │
│  │  │              │              │              │     │  │
│  │  │  ┌────────┐  │              │  ┌────────┐  │     │  │
│  │  │  │  NAT   │  │──────────────▶  │  Pods  │  │     │  │
│  │  │  │Gateway │  │              │  │        │  │     │  │
│  │  │  └────────┘  │              │  └────────┘  │     │  │
│  │  └──────────────┘              └──────────────┘     │  │
│  │                                                       │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                 │
│  │   RDS    │  │  Redis   │  │   ECR    │                 │
│  │ (Future) │  │ (Future) │  │          │                 │
│  └──────────┘  └──────────┘  └──────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

**Infrastructure:**
- ☁️ **AWS EKS** - Managed Kubernetes (v1.30)
- 🏗️ **Terraform** - Infrastructure as Code
- 🌐 **VPC** - Custom networking with public/private subnets
- 🔐 **IAM** - Role-based access control

**Backend Services:**
- 🟢 **Node.js** - Microservices runtime
- 🐳 **Docker** - Containerization
- ☸️ **Kubernetes** - Container orchestration

**Coming Soon:**
- 📊 **Prometheus & Grafana** - Monitoring
- 📝 **ELK Stack** - Logging
- 🔄 **GitHub Actions** - CI/CD

---

## 📁 Project Structure
```
cloud-native-ecommerce/
├── services/                    # Microservices
│   ├── user-service/           # User management & auth
│   ├── product-service/        # Product catalog
│   ├── order-service/          # Order processing
│   └── payment-service/        # Payment gateway
│
├── frontend/                    # React frontend (Coming Soon)
│
├── docker/                      # Dockerfiles
│   └── docker-compose.yml      # Local development
│
├── k8s/                        # Kubernetes manifests
│   ├── base/                   # Base configurations
│   └── overlays/               # Environment-specific
│
├── terraform/                  # Infrastructure as Code
│   ├── modules/                # Reusable Terraform modules
│   │   ├── vpc/               # VPC, Subnets, NAT
│   │   ├── eks/               # EKS Cluster & Node Groups
│   │   └── security/          # IAM Roles & Policies
│   │
│   └── environments/          # Environment configurations
│       ├── dev/               # Development environment
│       └── prod/              # Production (Coming Soon)
│
├── .github/workflows/          # CI/CD pipelines
│
├── docs/                       # Documentation
│   └── docker-guide.md
│
└── scripts/                    # Utility scripts
    └── push-to-ecr.sh         # Push images to ECR
```

---

## 🚀 Current Implementation Status

### ✅ Phase 0: Planning & AWS Foundation
- [x] AWS account setup
- [x] IAM user with programmatic access
- [x] AWS CLI configured
- [x] Local development tools installed

### ✅ Phase 1: Application & Repository Structure
- [x] GitHub repository created
- [x] Project structure established
- [x] Microservices boilerplate (4 services)
- [x] Health check endpoints implemented

### ✅ Phase 2: Containerization
- [x] Multi-stage Dockerfiles for all services
- [x] Docker Compose for local development
- [x] Amazon ECR repositories created
- [x] Docker images built and pushed
- [x] Health checks implemented

### ✅ Phase 3: EKS Cluster with Terraform
- [x] VPC with public/private subnets (2 AZs)
- [x] NAT Gateway for private subnet internet access
- [x] IAM roles and policies for EKS
- [x] EKS Control Plane (Kubernetes 1.30)
- [x] EKS Node Group (2x t3.small instances)
- [x] Security groups configured
- [x] OIDC provider for IRSA

### 🔄 Phase 4: Kubernetes Deployments (Next)
- [ ] Kubernetes deployment manifests
- [ ] Service definitions
- [ ] ConfigMaps and Secrets
- [ ] Ingress controller setup
- [ ] Load balancer configuration

### 📅 Phase 5: CI/CD Pipeline (Upcoming)
- [ ] GitHub Actions workflows
- [ ] Automated testing
- [ ] Docker image building
- [ ] Automated deployments to EKS

### 📅 Phase 6: Observability (Upcoming)
- [ ] Prometheus deployment
- [ ] Grafana dashboards
- [ ] ELK Stack for logging
- [ ] CloudWatch integration

### 📅 Phase 7: Security & Production Hardening (Upcoming)
- [ ] Network policies
- [ ] Pod security policies
- [ ] Secrets management (AWS Secrets Manager)
- [ ] SSL/TLS certificates
- [ ] WAF configuration

---

## 🛠️ Getting Started

### Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured (`aws configure`)
- Terraform >= 1.0
- kubectl >= 1.28
- Docker >= 20.x
- Node.js >= 18.x

### Local Development

1. **Clone the repository:**
```bash
   git clone https://github.com/AhmadShaaban1/cloud-native-ecommerce.git
   cd cloud-native-ecommerce
```

2. **Run services locally with Docker Compose:**
```bash
   docker-compose up -d
```

3. **Test services:**
```bash
   curl http://localhost:3001/health  # User service
   curl http://localhost:3002/health  # Product service
   curl http://localhost:3003/health  # Order service
   curl http://localhost:3004/health  # Payment service
```

### Deploy to AWS EKS

1. **Navigate to Terraform dev environment:**
```bash
   cd terraform/environments/dev
```

2. **Initialize Terraform:**
```bash
   terraform init
```

3. **Review the plan:**
```bash
   terraform plan
```

4. **Deploy infrastructure:**
```bash
   terraform apply
```

5. **Configure kubectl:**
```bash
   aws eks update-kubeconfig --region us-east-1 --name ecommerce-dev
```

6. **Verify cluster:**
```bash
   kubectl get nodes
   kubectl get pods -A
```

---

## 🌐 Infrastructure Details

### AWS Resources Created

| Resource | Type | Configuration |
|----------|------|---------------|
| VPC | Network | 10.0.0.0/16 |
| Public Subnets | Network | 2x subnets across 2 AZs |
| Private Subnets | Network | 2x subnets across 2 AZs |
| NAT Gateway | Network | Single NAT for cost optimization |
| EKS Cluster | Compute | Kubernetes 1.30 |
| Node Group | Compute | 2x t3.small (free tier eligible) |
| Security Groups | Security | Cluster + Node SGs |
| IAM Roles | Security | Cluster + Node roles with policies |

### Cost Estimation (Monthly)

| Service | Configuration | Estimated Cost |
|---------|--------------|----------------|
| EKS Control Plane | 1 cluster | $73.00 |
| EC2 Instances | 2x t3.small | ~$30.00 (after free tier) |
| NAT Gateway | Single NAT | ~$32.00 |
| Data Transfer | Varies | ~$5-10 |
| **Total** | | **~$135-145/month** |

💡 **Cost Saving Tips:**
- Scale nodes to 0 when not in use
- Use `terraform destroy` to tear down environment
- Consider spot instances for non-production

---

## 📊 Monitoring & Health Checks

All services implement health check endpoints:
```bash
# User Service
curl http://localhost:3001/health

# Product Service  
curl http://localhost:3002/health

# Order Service
curl http://localhost:3003/health

# Payment Service
curl http://localhost:3004/health
```

---

## 🔐 Security

- ✅ IAM roles with least privilege principle
- ✅ Private subnets for EKS nodes
- ✅ Security groups with minimal required access
- ✅ Encrypted EKS cluster logs
- ✅ Non-root containers
- 🔄 Secrets management (coming in Phase 7)
- 🔄 Network policies (coming in Phase 7)

---

## 📚 Documentation

- [Docker Guide](./docs/docker-guide.md)
- [Terraform Guide](./docs/terraform-guide.md) *(Coming Soon)*
- [Kubernetes Guide](./docs/k8s-guide.md) *(Coming Soon)*
- [CI/CD Guide](./docs/cicd-guide.md) *(Coming Soon)*

---

## 🤝 Contributing

This is a learning project showcasing DevOps best practices. Feedback and suggestions are welcome!

---

## 📝 License

MIT License - Feel free to use this project for learning purposes.

---

## 👨‍💻 Author

**Ahmed Shaaban**
- GitHub: [@AhmadShaaban1](https://github.com/AhmadShaaban1)
- Project: [cloud-native-ecommerce](https://github.com/AhmadShaaban1/cloud-native-ecommerce)

---

## 🎯 Next Steps

1. ✅ **Phase 3 Complete** - EKS cluster is running
2. 🔄 **Phase 4 Next** - Deploy microservices to Kubernetes
3. 📅 **Phase 5 Coming** - Set up CI/CD pipeline
4. 📅 **Phase 6 Coming** - Add monitoring and logging

---

**⚡ Status:** Phase 3 Complete - EKS Cluster Running ✅

Last Updated: January 2, 2026