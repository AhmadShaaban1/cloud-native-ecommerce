# 🏗️ Terraform Infrastructure Guide

## Overview

This project uses Terraform to provision a production-grade EKS cluster on AWS.

## Structure
```
terraform/
├── modules/           # Reusable modules
│   ├── vpc/          # VPC, subnets, NAT
│   ├── eks/          # EKS cluster & node groups
│   └── security/     # IAM roles & policies
└── environments/     # Environment configs
    └── dev/          # Development environment
```

## Modules

### VPC Module (`modules/vpc`)

Creates:
- VPC with custom CIDR
- Public subnets (2 AZs)
- Private subnets (2 AZs)
- Internet Gateway
- NAT Gateway
- Route tables

### Security Module (`modules/security`)

Creates:
- EKS cluster IAM role
- EKS node group IAM role
- Required policy attachments

### EKS Module (`modules/eks`)

Creates:
- EKS control plane
- Node groups
- Security groups
- OIDC provider

## Commands
```bash
# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply

# Destroy
terraform destroy
```

## Cost Optimization

- Using t3.small instances (free tier eligible)
- Single NAT Gateway
- Can scale nodes to 0 when not in use

## Outputs

- `vpc_id` - VPC ID
- `eks_cluster_name` - Cluster name
- `eks_cluster_endpoint` - API endpoint
- `configure_kubectl` - kubectl config command