variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EKS"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for load balancers"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  type        = string
}

variable "node_role_arn" {
  description = "EKS node group IAM role ARN"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.34"
}

variable "node_instance_types" {
  description = "EC2 instance types for nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 6
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 4
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 15
}

variable "node_disk_size" {
  description = "Disk size for nodes (GB)"
  type        = number
  default     = 20
}

variable "ssh_key_name" {
  description = "SSH key name for node access"
  type        = string
  default     = null
}

variable "enable_karpenter" {
  description = "Enable Karpenter for cluster autoscaling"
  type        = bool
  default     = true
}

variable "karpenter_version" {
  description = "Version of Karpenter to install"
  type        = string
  default     = "v0.33.0"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
