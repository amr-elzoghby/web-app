provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project
      Owner       = var.owner
      Environment = "prod"
      ManagedBy   = "Terraform"
    }
  }
}

module "storage" {
  source = "../../../modules/storage"

  environment                 = "prod"
  aws_region                  = var.aws_region
  customer_data_bucket_prefix = "shop-prod-data"
}

output "bucket_name" {
  value = module.storage.bucket_name
}

output "bucket_arn" {
  value = module.storage.bucket_arn
}
