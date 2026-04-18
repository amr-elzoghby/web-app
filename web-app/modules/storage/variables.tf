variable "environment" {
  description = "Deployment environment"
  type        = string
}

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

variable "customer_data_bucket_prefix" {

  description = "Prefix for the S3 bucket that stores customer/login data backups"
  type        = string
}

variable "force_destroy" {
  description = "Force destroy the bucket"
  type        = bool
  default     = false
}

variable "sse_algorithm" {
  description = "S3 encryption algorithm"
  type        = string
  default     = "AES256"
}

variable "versioning_status" {
  description = "S3 versioning status"
  type        = string
  default     = "Enabled"
}

variable "backup_retention_days" {
  description = "S3 backup retention days"
  type        = number
  default     = 90
}

