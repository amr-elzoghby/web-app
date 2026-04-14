# ─── General ──────────────────────────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region to deploy all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

# ─── Networking ───────────────────────────────────────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for the main VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# ─── Compute ──────────────────────────────────────────────────────────────────
variable "instance_type" {
  description = "EC2 instance type for the Auto Scaling Group"
  type        = string
  default     = "t3.micro"
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances in the ASG"
  type        = number
  default     = 2
}

variable "asg_min_size" {
  description = "Minimum number of EC2 instances in the ASG"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in the ASG"
  type        = number
  default     = 4
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
  default     = "first"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (Ubuntu 22.04 us-east-1)"
  type        = string
  default     = "ami-0ec10929233384c7f"
}

# ─── Application ──────────────────────────────────────────────────────────────
variable "db_password" {
  description = "PostgreSQL database password (sensitive)"
  type        = string
  sensitive   = true
}

variable "docker_image_tag" {
  description = "Docker image tag for the app (set by CI/CD)"
  type        = string
  default     = "latest"
}

# ─── S3 / Backups ─────────────────────────────────────────────────────────────
variable "customer_data_bucket_prefix" {
  description = "Prefix for the S3 bucket that stores customer/login data backups"
  type        = string
  default     = "shopmicro-customer-data"
}
