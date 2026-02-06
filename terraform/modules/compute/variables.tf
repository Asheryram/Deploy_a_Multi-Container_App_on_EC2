variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of EC2 key pair (null for no SSH key - use EC2 Instance Connect instead)"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "repo_url" {
  description = "Git repository URL to clone"
  type        = string
  default     = ""
}

variable "auto_start" {
  description = "Whether to auto-start the application after provisioning"
  type        = bool
  default     = true
}

variable "db_root_password" {
  description = "MySQL root password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "MySQL database name"
  type        = string
  default     = "appdb"
}

variable "db_user" {
  description = "MySQL user"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "MySQL user password"
  type        = string
  sensitive   = true
}

variable "frontend_port" {
  description = "Frontend port"
  type        = number
  default     = 3000
}

variable "backend_port" {
  description = "Backend API port"
  type        = number
  default     = 5000
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
