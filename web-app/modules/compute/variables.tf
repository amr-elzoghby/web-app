variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}


variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
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

variable "all_traffic_cidr" {

  description = "CIDR block for all traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ami_id" {

  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances in the ASG"
  type        = number
}

variable "asg_min_size" {
  description = "Minimum number of EC2 instances in the ASG"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of EC2 instances in the ASG"
  type        = number
}

variable "ebs_volume_size" {
  description = "EBS volume size"
  type        = number
  default     = 20
}

variable "ebs_volume_type" {
  description = "EBS volume type"
  type        = string
  default     = "gp3"
}

variable "ebs_device_name" {
  description = "EBS device name"
  type        = string
  default     = "/dev/sda1"
}

variable "asg_health_check_type" {
  description = "ASG health check type"
  type        = string
  default     = "ELB"
}

variable "asg_health_check_grace_period" {
  description = "ASG health check grace period"
  type        = number
  default     = 900
}

variable "http_port" {
  description = "HTTP port"
  type        = number
  default     = 80
}

variable "any_port" {
  description = "Any port"
  type        = number
  default     = 0
}

variable "any_protocol" {
  description = "Any protocol"
  type        = string
  default     = "-1"
}

variable "alb_health_check" {
  description = "ALB health check settings"
  type = object({
    path                = string
    healthy_threshold   = number
    unhealthy_threshold = number
    timeout             = number
    interval            = number
    matcher             = string
  })
  default = {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 30
    interval            = 60
    matcher             = "200-404"
  }
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Lambda timeout"
  type        = number
  default     = 30
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}






