data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "tf-state-ecommerce-microservices-3mr"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "storage" {
  backend = "s3"

  config = {
    bucket = "tf-state-ecommerce-microservices-3mr"
    key    = "storage/terraform.tfstate"
    region = "us-east-1"
  }
}



locals {
  vpc_id                = data.terraform_remote_state.network.outputs.vpc_id
  public_subnet_ids     = data.terraform_remote_state.network.outputs.public_subnet_ids
  private_subnet_ids    = data.terraform_remote_state.network.outputs.private_subnet_ids
  app_security_group_id = data.terraform_remote_state.network.outputs.app_security_group_id
  alb_security_group_id = data.terraform_remote_state.network.outputs.alb_security_group_id
  nat_gateway_ip        = data.terraform_remote_state.network.outputs.nat_gateway_ip
  
  s3_bucket_name        = data.terraform_remote_state.storage.outputs.bucket_name
  s3_bucket_arn         = data.terraform_remote_state.storage.outputs.bucket_arn
}
