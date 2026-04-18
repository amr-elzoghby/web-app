variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0ec10929233384c7f"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium" # Production grade instance
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
  default     = "first"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
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
