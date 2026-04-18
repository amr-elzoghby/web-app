output "bucket_name" {
  value = aws_s3_bucket.customer_data.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.customer_data.arn
}
