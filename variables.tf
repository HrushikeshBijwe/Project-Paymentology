variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Base name for the deployment"
  type        = string
  default     = "paymentology"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "az_count" {
  description = "Number of AZs to use"
  type        = number
  default     = 2
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.10.11.0/24", "10.10.12.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.10.21.0/24", "10.10.22.0/24"]
}

variable "create_database_subnets" {
  description = "Whether to create database subnets"
  type        = bool
  default     = false
}

variable "ssh_key_name" {
  description = "SSH key pair name to assign to compute instances"
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "Optional SSH public key material to create a key pair"
  type        = string
  default     = ""
}

variable "tls_certificate_pem" {
  description = "PEM-encoded certificate body for instances (optional)"
  type        = string
  default     = ""
}

variable "tls_private_key_pem" {
  description = "PEM-encoded private key for instances (optional)"
  type        = string
  default     = ""
}
