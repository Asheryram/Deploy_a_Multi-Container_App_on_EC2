variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
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

variable "ami_id" {
  description = "AMI ID for the EC2 instance (Amazon Linux 2). Find IDs at https://aws.amazon.com/amazon-linux-ami/"
  type        = string
  # Default: Amazon Linux 2 in us-east-1 (update for your region)
  default     = "ami-0c02fb55956c7d316"
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
  description = "CIDR block allowed to SSH (use your IP for security)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_port" {
  description = "Backend API port"
  type        = number
  default     = 5000
}

variable "frontend_port" {
  description = "Frontend port"
  type        = number
  default     = 3000
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "repo_url" {
  description = "Git repository URL to clone"
  type        = string
}

variable "auto_start" {
  description = "Auto-start the application after provisioning"
  type        = bool
  default     = true
}

# Database credentials (sensitive)
variable "db_root_password" {
  description = "MySQL root password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "MySQL database name"
  type        = string
}

variable "db_user" {
  description = "MySQL user"
  type        = string
}

variable "db_password" {
  description = "MySQL user password"
  type        = string
  sensitive   = true
}
