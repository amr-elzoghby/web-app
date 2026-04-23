resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "" 

  # 1. Origin: Connects CloudFront to your Load Balancer (ALB)
  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = "My-ALB-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only" 
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # 2. Cache Behavior: How CloudFront handles requests
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "My-ALB-origin"

    forwarded_values {
      query_string = true
      cookies {
        forward = "all" 
      }
    }

    viewer_protocol_policy = "allow-all" 
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # 3. Price Class: Choose locations 
  price_class = "PriceClass_100"

  # 4. Restrictions: Who can access
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # 5. Viewer Certificate: Default CloudFront SSL (*.cloudfront.net)
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = var.environment
    Name        = "${var.environment}-cdn"
  }
}