#############################
# Network
#############################

variable "subnet_ids" {
  description = "List of subnet IDs. Must be in at least two different availability zones."
  type        = list(string)
}

#############################
# EKS
#############################

variable "eks_version" {
  description = "Desired Kubernetes master version."
  type        = string
}

variable "eks_name" {
  description = "Name of the cluster."
  type        = string
}

variable "sleep_time_in_seconds" {
  description = "OIDC bot topic request sleep time in seconds."
  type        = number
  default     = 300
}

#############################
# Node
#############################

variable "http_tokens" {
  description = "HTTP tokens for metadata access"
  type        = string
  default     = "required"
}

variable "http_put_response_hop_limit" {
  description = "The number of hops for HTTP PUT response"
  type        = number
  default     = 5
}

variable "use_node_launch_template" {
  description = "Flag to determine whether to use the launch template"
  type        = bool
  default     = true
}

variable "node_ebs_size" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 50
}

variable "node_volume_type" {
  description = "Type of the EBS volume"
  type        = string
  default     = "gp2"
}

variable "enable_endpoint_private_access" {
  description = "Indicates whether eks private endpoint access is enabled"
  type        = bool
  default     = true
}

variable "enable_endpoint_public_access" {
  description = "Indicates whether eks cluster public endpoint access is enabled"
  type        = bool
  default     = false
}

variable "retention_in_days" {
  description = "Number of days to retain log events in the CloudWatch log group"
  type        = number
  default     = 7
}

#############################
# Encryption
#############################

variable "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption"
  type        = string
}

variable "encryption_resources" {
  description = "List of resources to be encrypted"
  type        = list(string)
  default     = ["secrets"]
}

#############################
# Worker Node
#############################

variable "node_iam_policies" {
  description = "List of IAM Policies to attach to EKS-managed nodes."
  type        = map(any)
  default = {
    1 = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    2 = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    3 = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    4 = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

variable "node_groups" {
  description = "EKS node groups"
  type        = map(any)
}

variable "max_unavailable" {
  description = "Node group Role ARN."
  type        = number
  default     = 1
}


#############################
# Tags
#############################

variable "tags" {
  description = "Default tags to associate to these resources"
  type        = map(string)
  default     = {}
}
