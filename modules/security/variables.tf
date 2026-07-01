variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups are created"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
