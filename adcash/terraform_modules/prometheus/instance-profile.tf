resource "aws_iam_instance_profile" "this" {
  count = var.ec2_iam_role != null ? 1 : 0

  role = var.ec2_iam_role

  tags = var.tags
}
