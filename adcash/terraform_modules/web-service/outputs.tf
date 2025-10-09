output "eks_name" {
  description = "The name of the Amazon EKS cluster."
  value       = aws_eks_cluster.this.id
}

output "node_role_arn" {
  description = "The ARN (Amazon Resource Name) of the IAM role associated with the Amazon EKS worker nodes."
  value       = aws_iam_role.node.arn
}

output "node_template_name" {
  description = "The name of the Node Group template."
  value       = var.use_node_launch_template ? var.use_node_launch_template : ""
}

output "eks_cluster_security_group_id" {
  description = "The security ID of the Amazon EKS cluster."
  value       = aws_eks_cluster.this.vpc_config.0.cluster_security_group_id
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "launch_template_id" {
  description = "Nodegroup launch template id."
  value       = var.use_node_launch_template ? aws_launch_template.this[0].id : null
}

output "launch_template_version" {
  description = "Nodegroup launch template version."
  value       = var.use_node_launch_template ? aws_launch_template.this[0].latest_version : null
}
