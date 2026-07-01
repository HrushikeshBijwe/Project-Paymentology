variable "project_name" {
  description = "Project name prefix for IAM resources"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
