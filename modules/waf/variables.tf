variable "project_name" {
  description = "Project name prefix for WAF resources"
  type        = string
}

variable "alb_arn" {
  description = "ALB ARN used for any WAF ACL bindings or future protections"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
