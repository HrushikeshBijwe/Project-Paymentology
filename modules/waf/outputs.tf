output "cloudfront_web_acl_arn" {
  value = aws_wafv2_web_acl.cloudfront.arn
}

output "alb_web_acl_arn" {
  value = aws_wafv2_web_acl.regional.arn
}
