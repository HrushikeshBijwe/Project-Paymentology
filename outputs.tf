output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = module.loadbalancer.alb_dns_name
}

output "api_gateway_url" {
  description = "Invokable URL for the API Gateway"
  value       = module.api_gateway.invoke_url
}

# output "cloudfront_domain_name" {
#   description = "CloudFront distribution domain name"
#   value       = module.cloudfront.domain_name
# }

output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "monitoring_log_group" {
  description = "CloudWatch log group name"
  value       = module.monitoring.log_group_name
}
