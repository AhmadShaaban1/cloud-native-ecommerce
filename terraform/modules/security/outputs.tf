output "eks_cluster_role_arn" {
  description = "ARN of EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_group_role_arn" {
  description = "ARN of EKS node group IAM role"
  value       = aws_iam_role.eks_node_group.arn
}

output "eks_cluster_role_name" {
  description = "Name of EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster.name
}

output "eks_node_group_role_name" {
  description = "Name of EKS node group IAM role"
  value       = aws_iam_role.eks_node_group.name
}