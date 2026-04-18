module "network" {
  source = "../../../modules/network"

  environment = "dev"
  name_prefix = "shop-dev"
  vpc_cidr    = var.vpc_cidr
  aws_region  = var.aws_region
  
  subnets = {
    public_1  = "10.0.1.0/24"
    public_2  = "10.0.2.0/24"
    private_1 = "10.0.3.0/24"
    private_2 = "10.0.4.0/24"
  }
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "app_security_group_id" {
  value = module.network.app_security_group_id
}

output "alb_security_group_id" {
  value = module.network.alb_security_group_id
}
