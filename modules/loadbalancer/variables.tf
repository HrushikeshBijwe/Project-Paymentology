variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the target group"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "tls_certificate_arn" {
  description = "Optional ACM certificate ARN to use for HTTPS listener. If empty, tls_certificate_pem and tls_private_key_pem may be provided to import a certificate into ACM."
  type        = string
  default     = ""
}

# variable "tls_certificate_pem" {
#   description = "PEM-encoded certificate body to import into ACM (self-signed allowed)."
#   type        = string
#   default     = ""
# }

# variable "tls_private_key_pem" {
#   description = "PEM-encoded private key corresponding to the certificate."
#   type        = string
#   default     = ""
# }

# variable "tls_certificate_chain_pem" {
#   description = "Optional PEM-encoded certificate chain."
#   type        = string
#   default     = ""
# }
