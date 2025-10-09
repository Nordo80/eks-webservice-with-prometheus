resource "aws_instance" "this" {
  subnet_id              = var.ec2_subnet_id
  vpc_security_group_ids = var.ec2_security_group_ids
  ebs_optimized          = var.ebs_optimized
  monitoring             = var.monitoring
  key_name               = var.key_pair_name != null ? var.key_pair_name : null

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  metadata_options {
    http_endpoint = var.http_endpoint
    http_tokens   = var.http_tokens
  }

  root_block_device {
    encrypted   = var.ec2_root_block_device.encrypted
    volume_size = var.ec2_root_block_device.volume_size
    kms_key_id  = var.ec2_root_block_device.kms_key_arn
  }

  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = var.ec2_private_dns_name_options.enable_resource_name_dns_aaaa_record
    enable_resource_name_dns_a_record    = var.ec2_private_dns_name_options.enable_resource_name_dns_a_record
    hostname_type                        = var.ec2_private_dns_name_options.hostname_type
  }

  tags = var.tags
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = var.ec2_lb_target_group_arns != null ? var.ec2_lb_target_group_arns : {}

  target_group_arn = each.value
  target_id        = aws_instance.this.id
}
