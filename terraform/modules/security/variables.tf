variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH"
  type        = string
}

variable "app_port" {
  description = "Application port to expose"
  type        = number
  default     = 5000
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
