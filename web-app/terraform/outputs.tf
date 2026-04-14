# ─── Load Balancer DNS ────────────────────────────────────────────────────────
output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer — open this in your browser"
  value       = "http://${aws_lb.main.dns_name}"
}

# ─── Customer Data S3 Bucket ──────────────────────────────────────────────────
output "customer_data_bucket" {
  description = "S3 bucket storing MongoDB customer/order data backups (every 6 hours)"
  value       = aws_s3_bucket.customer_data.bucket
}

output "customer_data_bucket_arn" {
  description = "ARN of the customer data S3 bucket (for IAM policies or cross-account access)"
  value       = aws_s3_bucket.customer_data.arn
}

# ─── Networking ───────────────────────────────────────────────────────────────
output "vpc_id" {
  description = "ID of the main VPC"
  value       = aws_vpc.main.id
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway (egress IP for private instances)"
  value       = aws_eip.nat.public_ip
}