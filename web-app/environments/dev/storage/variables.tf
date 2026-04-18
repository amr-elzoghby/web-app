variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "ecommerce-microservices"
}

variable "owner" {
  description = "Project owner"
  type        = string
  default     = "3mr-devops"
}
