variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type (t2.micro is Free Tier eligible)"
  type        = string
  default     = "t2.micro"
}

variable "create_key_pair" {
  description = "Whether to create a new key pair (true) or use existing (false)"
  type        = bool
  default     = true
}

variable "key_name" {
  description = "Name of existing EC2 key pair (only used if create_key_pair is false)"
  type        = string
  default     = ""
}

variable "key_path" {
  description = "Path to save the generated private key"
  type        = string
  default     = "."
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH (use your IP for security, e.g., 1.2.3.4/32)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_port" {
  description = "Application port to expose"
  type        = number
  default     = 5000
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "repo_url" {
  description = "Git repository URL to clone"
  type        = string
  default     = "https://github.com/YOUR_USERNAME/Deploy_a_Multi-Container_App_on_EC2.git"
}
