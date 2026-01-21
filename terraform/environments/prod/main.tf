terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module - Production with 3 AZs
module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = "10.1.0.0/16"
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  private_subnet_cidrs = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = false  # Multi-AZ NAT for HA in production
}

# Security Module
module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = var.environment
}

# EKS Module - Production with m6i.large
module "eks" {
  source = "../../modules/eks"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  cluster_role_arn   = module.security.eks_cluster_role_arn
  node_role_arn      = module.security.eks_node_group_role_arn
  
  kubernetes_version   = "1.34"
  
  # PRODUCTION: m6i.large for better performance and stability
  node_instance_types  = ["m6i.large"]  # 2 vCPU, 8GB RAM, better network
  node_desired_size    = 6
  node_min_size        = 4
  node_max_size        = 10
  node_disk_size       = 50  # More storage for production
}