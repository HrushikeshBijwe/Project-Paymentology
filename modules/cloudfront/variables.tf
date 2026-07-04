variable "project_name" {
  description = "Project name prefix for CloudFront resources"
  type        = string
}

variable "origin_domain_name" {
  description = "Origin domain name for CloudFront, typically the ALB DNS name"
  type        = string
}

variable "web_acl_arn" {
  description = "ARN of the WAF web ACL to associate with CloudFront"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
