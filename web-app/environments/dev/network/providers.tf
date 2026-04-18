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
