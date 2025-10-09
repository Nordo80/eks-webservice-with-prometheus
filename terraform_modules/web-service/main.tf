#############################
# Cluster
#############################

resource "aws_eks_cluster" "this" {

  name     = local.eks_name
  version  = var.eks_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    endpoint_private_access = var.enable_endpoint_private_access
    endpoint_public_access  = var.enable_endpoint_public_access
    subnet_ids              = var.subnet_ids
  }

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = var.encryption_resources
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.cluster
  ]
}

#############################
# Node group
#############################

resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node.arn

  subnet_ids     = var.subnet_ids
  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  update_config {
    max_unavailable = var.max_unavailable
  }

  launch_template {
    id      = var.use_node_launch_template ? aws_launch_template.this[0].id : null
    version = var.use_node_launch_template ? aws_launch_template.this[0].latest_version : null
  }


  lifecycle {
    ignore_changes = [
      scaling_config.0.desired_size
    ]
  }

  labels = each.value.node_labels

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.node
  ]

}
