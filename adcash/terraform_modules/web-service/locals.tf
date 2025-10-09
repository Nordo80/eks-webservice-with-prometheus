locals {
  eks_name             = var.eks_name
  node_name            = "${var.eks_name}-node"
  account_id           = data.aws_caller_identity.current.account_id
  region               = data.aws_region.current.name
}
