variable "name_prefix" {
  description = "Prefix for the key pair name"
  type        = string
}

variable "key_path" {
  description = "Path to save the private key file"
  type        = string
  default     = "."
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
