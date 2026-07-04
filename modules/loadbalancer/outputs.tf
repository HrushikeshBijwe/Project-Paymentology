output "alb_dns_name" {
  value = aws_lb.pamentology_alb.dns_name
}

output "alb_arn" {
  value = aws_lb.pamentology_alb.arn
}

output "alb_arn_suffix" {
  value = join("/", slice(split("/", aws_lb.pamentology_alb.arn), 1, 4))
}

output "alb_name" {
  value = aws_lb.pamentology_alb.name
}

output "target_group_arn" {
  value = aws_lb_target_group.web.arn
}

output "target_group_arn_suffix" {
  value = join("/", slice(split("/", aws_lb_target_group.web.arn), 1, 3))
}
