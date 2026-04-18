locals {
  services = [
    "frontend",
    "cart-service",
    "catalog-service",
    "order-service",
    "payment-service",
    "user-service"
  ]
}

resource "aws_ecr_repository" "services" {
  for_each = toset(local.services)

  name                 = "${var.environment}-${each.value}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # Allows Terraform to delete the repo even if it has images

  image_scanning_configuration {
    scan_on_push = true # Automatically scans your images for security bugs
  }

  tags = {
    Environment = var.environment
    Name        = "${var.environment}-${each.value}-repo"
  }
}

