module "web-service" {
  source = "../../../../terraform_modules/web-service"
  eks_version = 1.33
  eks_name = "web-service"
  kms_key_arn = "arn:aws:kms:eu-central-1:091590067827:key/65ec6561-12ed-4ff4-8ee9-16b9975374c0"
  subnet_ids = ["subnet-047bd3700a70435c4", "subnet-0d2a73efff0a1764e"]
  enable_endpoint_public_access = true
  node_groups = {
    webservice_workload = {
      capacity_type  = "ON_DEMAND"
      instance_types = ["t3.small"]

      scaling_config = {
        desired_size = 1
        max_size     = 2
        min_size     = 1
      }

      node_labels = {
        Environment = "Test"
        Application = "Web-service"
      }
    }
  }
}
