variable "ec2_ami" {
  description = "The ID of the Amazon Machine Image (AMI) to use for the EC2 instances."
  type        = string
}

variable "ec2_instance_type" {
  description = "The type of EC2 instance to launch."
  type        = string
  default     = "t2.micro"
}

variable "ec2_block_device_mappings" {
  description = "A list of block device mappings for the EC2 instances."
  type = list(object({
    device_name = string
    volume_size = number
  }))
  default = null
}

variable "ec2_subnet_id" {
  description = "A subnet ID where the instance will be launched."
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data for configuring instances, including a template name and variables."
  type = object({
    template_name = string
    variables     = any
  })
  default = null
}

variable "ec2_lb_target_group_arns" {
  description = "A list of target group ARNs associated with the load balancer."
  type        = map(string)
  default     = null
}

variable "ec2_iam_role" {
  description = "The IAM role to be associated with the EC2 instances."
  type        = string
  default     = null
}

variable "ec2_security_group_ids" {
  description = "A list of security group IDs to associate with the EC2 instances."
  type        = list(string)
  default     = []
}

variable "ec2_launch_template_name" {
  description = "Name of the launch template to be created"
  type        = string
}

variable "ebs_optimized" {
  description = <<-DESCRIPTION
    Determine whether the instance should be EBS-optimized.
    This might result in terraform apply failure when an unsupported instance is specified. This can be very difficult to troubleshot.
    If any upstream instantiation needs this feature, it can be enabled.
    More info - https://stackoverflow.com/questions/45691826/aws-launch-configuration-error-the-requested-configuration-is-currently-not-sup
              - https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/troubleshooting-launch.html#troubleshooting-instance-configuration
  DESCRIPTION
  type        = bool
  default     = false
}

variable "monitoring" {
  description = "Whether detailed monitoring should be enabled."
  type        = bool
  default     = true
}

variable "http_endpoint" {
  description = "Whether the metadata service has an HTTP endpoint."
  type        = string
  default     = "enabled"
}

variable "http_tokens" {
  description = "Whether the metadata service requires session tokens."
  type        = string
  default     = "required"
}

variable "ec2_root_block_device" {
  description = "Root block device configuration."
  type = object({
    encrypted   = optional(bool, true)
    volume_size = number
    kms_key_arn = string
  })
}

variable "key_pair_name" {
  description = "Key pair name"
  type        = string
  default     = "ansible-prometheus"
}

variable "http_hop_limit" {
  description = "Desired HTTP PUT response hop limit for instance metadata requests."
  type        = number
  default     = 1
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "ec2_private_dns_name_options" {
  description = "Configuration for private DNS name options"
  type = object({
    enable_resource_name_dns_aaaa_record = bool
    enable_resource_name_dns_a_record    = bool
    hostname_type                        = string
  })
  default = {
    enable_resource_name_dns_aaaa_record = null
    enable_resource_name_dns_a_record    = null
    hostname_type                        = "resource-name"
  }
}

variable "iam_actions_allow" {
  description = "A list of IAM actions to allow."
  type        = list(string)
  default     = []
}

variable "iam_actions_allow_resources" {
  description = "A list of resources for which the IAM actions are allowed."
  type        = list(string)
  default     = []
}

variable "iam_policy" {
  description = "IAM policy configuration specifying the effect, actions, and resources."
  type = map(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  default = {}
}

variable "iam_policy_name" {
  description = "The name of the IAM policy."
  type        = string
}

variable "iam_role_name" {
  description = "The name of the IAM role."
  type        = string
}

variable "iam_assume_role_policy" {
  description = "The policy for assuming the role."
  type = object({
    effect  = optional(string, "Allow")
    actions = optional(list(string), ["sts:AssumeRole"])
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })), [{ type = "Service", identifiers = ["ec2.amazonaws.com"] }])
  })

  default = {}
}

variable "iam_additional_policies" {
  description = "Additional IAM policies to attach to the IAM role."
  type        = list(string)
  default     = []
}

variable "sg_name" {
  description = "The name of the security group."
  type        = string
}

variable "sg_vpc_id" {
  description = "The ID of the VPC associated with the security group."
  type        = string
}

variable "sg_description" {
  description = "The description of the security group."
  type        = string
  default     = ""
}

variable "sg_ingress_rules" {
  description = "Ingress rules for the security group."
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    description     = string
    security_groups = optional(list(string))
  }))
  default = [{
    from_port       = 9090
    to_port         = 9090
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow prometheus port"
    },
    {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Allow ssh"
    }]
}

variable "sg_egress_rules" {
  description = "Egress rules for the security group."
  type = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    description     = string
    security_groups = optional(list(string))
  }))
  default = [
    {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      description     = "Allow all"
      security_groups = []
    }
  ]
}
