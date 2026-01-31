variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "ecommerce"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
variable "karpenter_version" {
  description = "Karpenter version to deploy"
  type        = string
  default     = "v0.33.0"
}