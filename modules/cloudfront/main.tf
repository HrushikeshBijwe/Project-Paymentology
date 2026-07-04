# Create the Paymentology CloudFront distribution
resource "aws_cloudfront_distribution" "paymentology_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""
  web_acl_id          = var.web_acl_arn

  origin {
    domain_name = var.origin_domain_name
    origin_id   = "${var.project_name}-alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${var.project_name}-alb-origin"

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["Host", "Origin", "Referer", "User-Agent"]
    }

    min_ttl     = 0
    default_ttl = 60
    max_ttl     = 600
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.tags
}

