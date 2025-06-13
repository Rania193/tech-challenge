variable "project_name" {
  description = "Project name for parameter paths"
  type        = string
}

variable "environment" {
  description = "Environment for parameters"
  type        = string
}

variable "parameters" {
  description = "Map of parameter names and values"
  type        = map(string)
}