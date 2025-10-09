resource "aws_launch_template" "this" {
  count = var.use_node_launch_template ? 1 : 0

  name = "${var.eks_name}-node-group"

  # Required by the policy
  metadata_options {
    http_tokens                 = var.http_tokens
    http_put_response_hop_limit = var.http_put_response_hop_limit
  }

  block_device_mappings {
    device_name = "/dev/xvdb"
    ebs {
      volume_size = var.node_ebs_size
      volume_type = var.node_volume_type
    }
  }
}
