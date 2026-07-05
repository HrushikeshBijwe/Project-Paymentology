variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

variable "desired_capacity" {
  description = "Desired number of instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances"
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of instances"
  type        = number
  default     = 2
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ASG placement"
  type        = list(string)
}

variable "web_security_group_id" {
  description = "Security group for EC2 instances"
  type        = string
}

variable "target_group_arn" {
  description = "Target group ARN for register instances"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
}

variable "environment" {
  description = "Deployment environment for instance user data"
  type        = string
  default     = "dev"
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to attach to instances. If empty and ssh_public_key is provided, a key pair will be created with a generated name."
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "Public SSH key material. If provided, an aws_key_pair will be created and instances will use it."
  type        = string
  default     = ""
}

variable "tls_certificate_pem" {
  description = "PEM-encoded certificate body to install on instances (for HTTPS)"
  type        = string
  default     = ""
}

variable "tls_private_key_pem" {
  description = "PEM-encoded private key to install on instances (for HTTPS)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
