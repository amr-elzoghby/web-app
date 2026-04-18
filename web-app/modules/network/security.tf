# ─── ALB Security Group (public-facing) ───────────────────────────────────────
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Allow HTTP traffic from the internet to the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = var.all_traffic_cidr
  }

  egress {
    description = "Allow all outbound"
    from_port   = var.any_port
    to_port     = var.any_port
    protocol    = var.any_protocol
    cidr_blocks = var.all_traffic_cidr
  }

  tags = {
    Name = "${var.name_prefix}-alb-sg"
  }
}

# ─── App Security Group (private — only from ALB) ─────────────────────────────
resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-app-sg"
  description = "Allow HTTP traffic only from the ALB security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = var.http_port
    to_port         = var.http_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound (for Docker pulls, package installs)"
    from_port   = var.any_port
    to_port     = var.any_port
    protocol    = var.any_protocol
    cidr_blocks = var.all_traffic_cidr
  }

  tags = {
    Name = "${var.name_prefix}-app-sg"
  }
}