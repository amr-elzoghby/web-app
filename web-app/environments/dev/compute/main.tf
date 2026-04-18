provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project
      Owner       = var.owner
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}

module "compute" {
  source = "../../../modules/compute"

  environment      = "dev"
  name_prefix      = "shop-dev"
  aws_region       = var.aws_region
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  key_name         = var.key_name
  db_password      = var.db_password
  
  asg_desired_capacity = 1
  asg_min_size         = 1
  asg_max_size         = 2

  network_remote_state_key = "dev/network/terraform.tfstate"
  storage_remote_state_key = "dev/storage/terraform.tfstate"
}

output "alb_dns_name" {
  value = module.compute.alb_dns_name
}
