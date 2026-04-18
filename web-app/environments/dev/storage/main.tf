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

module "storage" {
  source = "../../../modules/storage"

  environment                 = "dev"
  aws_region                  = var.aws_region
  customer_data_bucket_prefix = "shop-dev-data"
}

output "bucket_name" {
  value = module.storage.bucket_name
}

output "bucket_arn" {
  value = module.storage.bucket_arn
}
