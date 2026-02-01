# 🛒 Cloud-Native E-Commerce Platform

A **production-grade cloud-native e-commerce system** built using **microservices architecture**, **Kubernetes (Amazon EKS)**, and **AWS-native services**, with **fully automated CI/CD pipelines** powered by **GitHub Actions**.

This project demonstrates real-world **DevOps, Cloud, and GitOps practices**, including secure ingress, observability, secrets management, and zero-downtime deployments.

---

## 🧱 High-Level Architecture

- **Single Amazon EKS cluster** (`ecommerce-dev`)
- **4 worker nodes** (`t3.medium`)
- **AWS Application Load Balancer (ALB) Ingress Controller**
- **Path-based routing** for frontend and backend APIs
- **TLS termination** using AWS ACM
- **Independent CI/CD pipelines** per service
- **GitOps** with Argo CD

---

## ☸ Kubernetes Cluster Details

| Component | Value |
|--------|------|
| Cluster | Amazon EKS |
| Environment | Dev |
| Node Count | 4 |
| Instance Type | `t3.medium` |
| Ingress | AWS ALB (internet-facing) |
| Networking | AWS VPC CNI |

---

## 🧩 Microservices

### Application Services

| Service | Replicas | Description |
|------|---------|------------|
| frontend | 3 | React web application |
| user-service | 2 | Authentication & user management |
| product-service | 2 | Product catalog |
| order-service | 2 | Order processing |
| payment-service | 2 | Payment handling |

### Supporting Services

| Component | Purpose |
|--------|--------|
| MongoDB | Primary database |
| Redis | Caching & performance |
| JWT Server | Token issuing & validation |

---

## 🌐 Ingress & Traffic Routing

The application is exposed via **AWS Application Load Balancer** using a custom domain:

https://cloudcommerce-shaaban.com


### Routing Rules

| Path | Backend Service |
|----|----------------|
| `/` | frontend |
| `/api/auth` | user-service |
| `/api/products` | product-service |
| `/api/orders` | order-service |
| `/api/payments` | payment-service |

### Security
- HTTPS enforced
- TLS certificates managed via **AWS ACM**
- SSL policy: `TLS13-1-2-2021-06`
- Health checks enabled (`/health`)

---

## 🔁 CI/CD – GitHub Actions

Each service has its **own dedicated CI/CD pipeline**.

### CI/CD Workflow
1. Code checkout
2. Dependency installation
3. Run tests (when available)
4. Build Docker image
5. Push image to **Amazon ECR**
6. Deploy to **Amazon EKS**
7. Verify rollout & pod health

### Pipelines Implemented
- Frontend CI/CD
- User Service CI/CD
- Product Service CI/CD
- Order Service CI/CD
- Payment Service CI/CD

✔ Uses GitHub Secrets  
✔ Rolling updates  
✔ Zero-downtime deployments  

---

## 📦 Container Registry

- **Amazon ECR**
- Images tagged with:
  - `latest`
  - Git commit SHA

---

## 🔐 Security & Secrets Management

- **HashiCorp Vault**
  - Centralized secrets management
- **GitHub Secrets**
  - AWS credentials and cluster configuration
- **Kubernetes Secrets**
  - Runtime secret injection

> 🚫 No secrets are committed to source control.

---

## 📊 Observability & Monitoring

### Monitoring
- Prometheus
- Grafana
- Metrics Server

### Logging
- Loki
- Promtail

### Tracing
- OpenTelemetry Collector

This stack provides **metrics, logs, and traces** across the entire platform.

---

## 🚀 GitOps & Automation

- **Argo CD**
  - GitOps-based deployments
  - Continuous reconciliation
- **Karpenter**
  - Cluster autoscaling
- **AWS EBS CSI Driver**
  - Persistent storage provisioning

---

## 📁 Repository Structure

```bash
cloud-native-ecommerce/
│── frontend/
│── services/
│   ├── user-service/
│   ├── product-service/
│   ├── order-service/
│   └── payment-service/
│── k8s/
│── terraform/
│── scripts/
│── .github/workflows/
│── README.md
---

## 🎯 Key DevOps Skills Demonstrated

Kubernetes (EKS) production deployments

AWS ALB ingress & networking

Microservices architecture

CI/CD with GitHub Actions

GitOps using Argo CD

Secure secret management (Vault)

Observability and monitoring

Real-world troubleshooting & rollouts

👤 Author

Ahmed Shaaban
DevOps / Cloud Engineer

🔗 GitHub:
https://github.com/AhmadShaaban1

⭐ If you find this project useful, feel free to star the repository.