module "ec2" {
  source = "../../../../terraform_modules/prometheus"
  ec2_launch_template_name  = "prometheus"
  ec2_ami = "ami-08697da0e8d9f59ec"
  ec2_root_block_device = {
    volume_size = 40
    kms_key_arn = "arn:aws:kms:eu-central-1:091590067827:key/65ec6561-12ed-4ff4-8ee9-16b9975374c0"
  }
  user_data = {
    template_name = "prometheus.tmpl"
    variables = {
      aws_region         = "eu-central-1"
    }
  }
  ec2_iam_role = "prometheus-role"
  iam_role_name           = "prometheus-role"
  iam_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore","arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"]
  iam_policy_name         = "prometheus-policy"
  sg_name = "prometheus-sg"
  sg_vpc_id = "vpc-0ced55de2418415d2"
  sg_description = "Prometheus security group"
}
