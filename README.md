
---

# ☁️ Cloud-Native E-Commerce Platform

A production-grade microservices architecture deployed on **AWS EKS** using modern DevOps practices.

![Project Status](https://img.shields.io/badge/Status-In%20Development-yellow)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.30-blue)
![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple)
![AWS](https://img.shields.io/badge/AWS-EKS-orange)

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

### 📅 Phase 6 – Observability
- Prometheus & Grafana
- Logging & alerting

### 📅 Phase 7 – Security Hardening
- Network policies
- Pod Security Standards
- Secrets management
- TLS & RBAC hardening

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
