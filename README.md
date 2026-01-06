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
│ AWS Cloud                                                   │
│ ┌───────────────────────────────────────────────────────┐ │
│ │ VPC (10.0.0.0/16)                                     │ │
│ │                                                       │ │
│ │ ┌──────────────┐              ┌──────────────┐      │ │
│ │ │ Public       │              │ Private      │      │ │
│ │ │ Subnets      │              │ Subnets      │      │ │
│ │ │              │              │              │      │ │
│ │ │ ┌────────┐   │              │ ┌────────┐   │      │ │
│ │ │ │ ALB    │   │              │ │ EKS    │   │      │ │
│ │ │ │        │   │              │ │ Nodes  │   │      │ │
│ │ │ └────────┘   │              │ └────────┘   │      │ │
│ │ │              │              │              │      │ │
│ │ │ ┌────────┐   │   ┌─────────▶ │ ┌────────┐   │      │ │
│ │ │ │ NAT    │───┼───┤          │ │ Pods   │   │      │ │
│ │ │ │ Gateway│   │   │          │ │        │   │      │ │
│ │ │ └────────┘   │   └─────────▶ │ └────────┘   │      │ │
│ │ └──────────────┘              └──────────────┘      │ │
│ └───────────────────────────────────────────────────────┘ │
│                                                           │
│ ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│ │ RDS      │  │ Redis    │  │ ECR      │              │
│ │ (Future) │  │ (Future) │  │ (Present)│              │
│ └──────────┘  └──────────┘  └──────────┘              │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

**Infrastructure:**
- ☁️ **AWS EKS** - Managed Kubernetes (v1.30)
- 🏗️ **Terraform** - Infrastructure as Code
- 🌐 **VPC** - Custom networking with public/private subnets
- 🔐 **IAM** - Role-based access control
- 📦 **ECR** - Container image registry

**Backend Services:**
- 🟢 **Node.js** - Microservices runtime
- 🐳 **Docker** - Containerization
- ☸️ **Kubernetes** - Container orchestration

**Observability & Monitoring:**
- 📊 **Prometheus** - Metrics collection
- 📈 **Grafana** - Metrics visualization
- 📝 **Loki** - Log aggregation
- 🔍 **Promtail** - Log shipper
- 📌 **Node Exporter** - System metrics
- 📋 **Kube State Metrics** - Kubernetes object metrics

**Coming Soon:**
- 🔄 **GitHub Actions** - CI/CD pipeline
- 🗄️ **RDS** - Managed relational database
- ⚡ **Redis** - Caching layer

---

## 📁 Project Structure

```
cloud-native-ecommerce/
├── services/                    # Microservices
│   ├── user-service/           # User management & authentication
│   ├── product-service/        # Product catalog & inventory
│   ├── order-service/          # Order processing & management
│   └── payment-service/        # Payment processing
│
├── k8s/                         # Kubernetes manifests
│   ├── deployments/            # Service deployments
│   ├── services/               # Kubernetes services
│   ├── configmaps/             # Configuration management
│   ├── observability/          # Prometheus, Grafana, Loki setup
│   └── namespaces/             # Namespace configurations
│
├── terraform/                   # IaC for AWS infrastructure
│   ├── modules/                # Reusable modules
│   │   ├── vpc/               # VPC & networking
│   │   ├── eks/               # EKS cluster
│   │   ├── iam/               # IAM roles & policies
│   │   └── ecr/               # ECR repositories
│   ├── environments/          # Environment-specific configs
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   └── main.tf               # Root module
│
├── scripts/                     # Helper scripts
│   ├── build.sh               # Docker build automation
│   ├── push-ecr.sh            # Push images to ECR
│   ├── deploy.sh              # Deploy to EKS
│   └── cleanup.sh             # Resource cleanup
│
├── docs/                        # Documentation
│   ├── SETUP.md               # Setup instructions
│   ├── DEPLOYMENT.md          # Deployment guide
│   └── ARCHITECTURE.md        # Architecture details
│
└── README.md                    # This file
```

---

## 🚀 Quick Start

### Prerequisites

- **AWS Account** with appropriate permissions
- **Terraform** >= 1.0
- **kubectl** >= 1.30
- **Docker** for building images
- **Git** for version control

### Local Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/AhmadShaaban1/cloud-native-ecommerce.git
   cd cloud-native-ecommerce
   ```

2. **Install dependencies:**
   ```bash
   # Install Node.js dependencies for each service
   cd services/user-service && npm install
   cd ../product-service && npm install
   cd ../order-service && npm install
   cd ../payment-service && npm install
   ```

3. **Set up environment variables:**
   ```bash
   # Copy example env file
   cp .env.example .env
   
   # Edit with your values
   nano .env
   ```

4. **Run services locally (development mode):**
   ```bash
   # Terminal 1: User Service (port 3001)
   cd services/user-service && npm start
   
   # Terminal 2: Product Service (port 3002)
   cd services/product-service && npm start
   
   # Terminal 3: Order Service (port 3003)
   cd services/order-service && npm start
   
   # Terminal 4: Payment Service (port 3004)
   cd services/payment-service && npm start
   ```

---

## 📊 Microservices Overview

### User Service
- **Port:** 3001
- **Responsibilities:** User registration, authentication, profile management
- **Database:** (Future: RDS PostgreSQL)
- **Key Endpoints:**
  - `POST /auth/register` - User registration
  - `POST /auth/login` - User login
  - `GET /users/:id` - Get user profile

### Product Service
- **Port:** 3002
- **Responsibilities:** Product catalog, inventory management, search
- **Database:** (Future: RDS PostgreSQL)
- **Key Endpoints:**
  - `GET /products` - List all products
  - `GET /products/:id` - Get product details
  - `POST /products` - Create product (admin)

### Order Service
- **Port:** 3003
- **Responsibilities:** Order creation, status tracking, order history
- **Database:** (Future: RDS PostgreSQL)
- **Key Endpoints:**
  - `POST /orders` - Create order
  - `GET /orders/:id` - Get order details
  - `GET /orders/user/:userId` - Get user orders

### Payment Service
- **Port:** 3004
- **Responsibilities:** Payment processing, transaction management
- **Database:** (Future: RDS PostgreSQL)
- **Key Endpoints:**
  - `POST /payments` - Process payment
  - `GET /payments/:id` - Get payment status
  - `POST /payments/:id/refund` - Refund payment

---

## 🔧 Infrastructure Deployment

### Phase 1: Infrastructure Setup (Terraform)

```bash
cd terraform/environments/dev

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -out=tfplan

# Apply configuration
terraform apply tfplan
```

### Phase 2: EKS Cluster Verification

```bash
# Update kubeconfig
aws eks update-kubeconfig --name cloud-native-ecommerce-cluster --region us-east-1

# Verify cluster connection
kubectl cluster-info
kubectl get nodes
```

### Phase 3: Deploy Services to EKS

```bash
# Build and push Docker images to ECR
./scripts/build.sh
./scripts/push-ecr.sh

# Deploy to Kubernetes
kubectl apply -f k8s/namespaces/
kubectl apply -f k8s/deployments/
kubectl apply -f k8s/services/
```

### Phase 4: Deploy Observability Stack

```bash
# Deploy Prometheus, Grafana, Loki
kubectl apply -f k8s/observability/

# Verify pods are running
kubectl get pods -n monitoring
```

---

## 📈 Monitoring & Logging

### Access Grafana Dashboard

```bash
# Port-forward to local machine
kubectl port-forward -n monitoring svc/grafana 3000:80

# Access at http://localhost:3000
# Default credentials: admin/admin
```

### Access Loki Logs

```bash
# Logs are aggregated in Grafana
# Navigate to Explore > Loki data source
# Query logs using LogQL
```

### Prometheus Metrics

```bash
# Port-forward Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Access at http://localhost:9090
```

---

## 🎯 Demo Scenario

This platform demonstrates a complete customer journey:

1. **User Registration** → User Service
2. **Browse Products** → Product Service
3. **Create Order** → Order Service
4. **Process Payment** → Payment Service
5. **Monitor Transaction** → Observability Stack (Prometheus/Grafana)
6. **View Logs** → Loki logs aggregation

**Example Flow:**
```
Customer registers (User Service)
         ↓
      Browse products (Product Service)
         ↓
      Add to cart & checkout
         ↓
      Create order (Order Service)
         ↓
      Process payment (Payment Service)
         ↓
      Confirm order & send notification
         ↓
      Monitor via Grafana dashboard
```

---

## 📚 Development Phases

- **Phase 0:** Project setup & repository initialization
- **Phase 1:** Infrastructure provisioning (Terraform + VPC + EKS)
- **Phase 2:** Microservices scaffolding & Docker containerization
- **Phase 3:** Kubernetes deployments & services
- **Phase 4:** Observability stack (Prometheus, Grafana, Loki)
- **Phase 5:** CI/CD pipeline (GitHub Actions)
- **Phase 6:** Security hardening & RBAC
- **Phase 7:** Production deployment & optimization

---

## 🔐 Security Considerations

- IAM roles with least privilege access
- Network segmentation (public/private subnets)
- Service-to-service authentication (mTLS - future)
- Secrets management (AWS Secrets Manager - future)
- Pod security policies & RBAC
- Container image scanning via ECR

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 📧 Contact

For questions or feedback, reach out to:
- **GitHub:** [@AhmadShaaban1](https://github.com/AhmadShaaban1)
- **Email:** ahmedshaaban2807@gmail.com

---

## 🙏 Acknowledgments

- AWS documentation and best practices
- Kubernetes community resources
- Terraform Registry modules
- Open-source tools (Prometheus, Grafana, Loki)
