output "aws_instance_id" {
  value = aws_instance.this.id
}

output "iam_role_name" {
  description = "IAM role name"
  value       = aws_iam_role.this.name
}

output "iam_role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.this.arn
}

output "securitygroup_id" {
  value = aws_security_group.this.id
}
