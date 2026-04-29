variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "me-south-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
