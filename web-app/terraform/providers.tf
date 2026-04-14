provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = local.project
      Owner       = local.owner
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}