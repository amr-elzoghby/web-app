# ─── Application Load Balancer ────────────────────────────────────────────────
resource "aws_lb" "main" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.alb_security_group_id]
  subnets            = local.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.name_prefix}-alb"
  }
}

# ─── Target Group ─────────────────────────────────────────────────────────────
resource "aws_lb_target_group" "app" {
  name_prefix = "web-tg"
  port        = var.http_port
  protocol    = "HTTP"
  vpc_id      = local.vpc_id

  health_check {
    path                = var.alb_health_check.path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = var.alb_health_check.healthy_threshold
    unhealthy_threshold = var.alb_health_check.unhealthy_threshold 
    timeout             = var.alb_health_check.timeout
    interval            = var.alb_health_check.interval
    matcher             = var.alb_health_check.matcher 
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.name_prefix}-tg"
  }
}

# ─── HTTP Listener ────────────────────────────────────────────────────────────
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}