# ─── IAM Role for EC2 (SSM access + S3 write) ────────────────────────────────
resource "aws_iam_role" "ec2" {
  name        = "${var.name_prefix}-ec2-role"
 description = "Role assumed by EC2 instances - allows SSM access and S3 writes for backups"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

# SSM — needed for Session Manager access (no SSH required)
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# S3 — allow EC2 to write customer data backups to our bucket
resource "aws_iam_role_policy" "s3_backup" {
  name = "s3-customer-backup-policy"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          local.s3_bucket_arn,
          "${local.s3_bucket_arn}/*"
        ]

      }
    ]
  })
}

# ─── Instance Profile ─────────────────────────────────────────────────────────
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
}

