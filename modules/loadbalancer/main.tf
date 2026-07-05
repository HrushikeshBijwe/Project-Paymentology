# Create the Paymentology application load balancer
resource "aws_lb" "paymentology_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  tags = merge(var.tags, { Name = "${var.project_name}-alb" })
}

resource "aws_lb_target_group" "web" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

/* Removed HTTP listeners (port 80) per request — ALB will only listen on HTTPS (443).
   Ensure a certificate is provided via `tls_certificate_arn` or `tls_certificate_pem` so
   the HTTPS listener can be created. */

# Import or use provided TLS certificate for HTTPS listener
# resource "aws_acm_certificate" "imported" {
#   count            = var.tls_certificate_arn == "" && var.tls_certificate_pem != "" ? 1 : 0
#   private_key      = var.tls_private_key_pem
#   certificate_body = var.tls_certificate_pem
#   certificate_chain = var.tls_certificate_chain_pem != "" ? var.tls_certificate_chain_pem : null

#   tags = merge(var.tags, { Name = "${var.project_name}-imported-cert" })
# }

# Create HTTPS listener if certificate available
resource "aws_lb_listener" "https" {
  #count             = var.tls_certificate_arn != "" ? 1 : (var.tls_certificate_pem != "" ? 1 : 0)
  load_balancer_arn = aws_lb.paymentology_alb.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = "arn:aws:acm:us-east-1:634512762993:certificate/87516c1b-2e5a-4aaf-8555-feb302186bcb"
  #ssl_policy = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

