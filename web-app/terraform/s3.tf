# ─── S3 Bucket — Customer Data Backups ───────────────────────────────────────

resource "aws_s3_bucket" "customer_data" {
  bucket        = "${var.customer_data_bucket_prefix}-${var.environment}"
  force_destroy = false # protect from accidental deletes in prod

  tags = {
    Name    = "${var.customer_data_bucket_prefix}-${var.environment}"
    Purpose = "CustomerDataBackup"
  }
}

# ─── Block ALL public access ──────────────────────────────────────────────────
resource "aws_s3_bucket_public_access_block" "customer_data" {
  bucket = aws_s3_bucket.customer_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─── Server-side encryption (AES-256) ────────────────────────────────────────
resource "aws_s3_bucket_server_side_encryption_configuration" "customer_data" {
  bucket = aws_s3_bucket.customer_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ─── Versioning — keep old backups safe ──────────────────────────────────────
resource "aws_s3_bucket_versioning" "customer_data" {
  bucket = aws_s3_bucket.customer_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ─── Lifecycle: auto-expire old backup versions after 90 days ────────────────
resource "aws_s3_bucket_lifecycle_configuration" "customer_data" {
  bucket = aws_s3_bucket.customer_data.id

  rule {
    id     = "expire-old-backups"
    status = "Enabled"

    filter {} 

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
