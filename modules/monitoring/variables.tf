variable "project_name" {
  description = "Project name prefix for monitoring resources"
  type        = string
}

variable "alb_name" {
  description = "Application Load Balancer name for ALB CloudWatch metrics"
  type        = string
}

variable "alb_arn_suffix" {
  description = "Application Load Balancer ARN suffix for CloudWatch dimensions"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ALB target group ARN suffix for CloudWatch dimensions"
  type        = string
}

variable "auto_scaling_group_name" {
  description = "Auto Scaling Group name for custom metric aggregation"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "alert_email" {
  description = "Email address to receive alerts (SNS subscription). A confirmation email will be sent.)"
  type        = string
  default     = "sarang.kolhe79@gmail.com"
}
