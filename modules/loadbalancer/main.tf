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

# Create the HTTP listener for the load balancer (forward when TLS not configured)
resource "aws_lb_listener" "http_forward" {
  count             = var.tls_certificate_arn == "" && var.tls_certificate_pem == "" ? 1 : 0
  load_balancer_arn = aws_lb.paymentology_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Create the HTTP listener for the load balancer (redirect to HTTPS when TLS configured)
resource "aws_lb_listener" "http_redirect" {
  count             = var.tls_certificate_arn != "" || var.tls_certificate_pem != "" ? 1 : 0
  load_balancer_arn = aws_lb.paymentology_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Import or use provided TLS certificate for HTTPS listener
resource "aws_acm_certificate" "imported" {
  count            = var.tls_certificate_arn == "" && var.tls_certificate_pem != "" ? 1 : 0
  private_key      = var.tls_private_key_pem
  certificate_body = var.tls_certificate_pem
  certificate_chain = var.tls_certificate_chain_pem != "" ? var.tls_certificate_chain_pem : null

  tags = merge(var.tags, { Name = "${var.project_name}-imported-cert" })
}

# Create HTTPS listener if certificate available
resource "aws_lb_listener" "https" {
  count             = var.tls_certificate_arn != "" ? 1 : (var.tls_certificate_pem != "" ? 1 : 0)
  load_balancer_arn = aws_lb.paymentology_alb.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = var.tls_certificate_arn != "" ? var.tls_certificate_arn : aws_acm_certificate.imported[0].arn

  ssl_policy = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

