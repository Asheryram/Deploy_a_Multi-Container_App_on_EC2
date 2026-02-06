terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix = "timesheet-app"
  common_tags = {
    Project     = "Timesheet App"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Key Pair Module (creates SSH key locally)
module "keypair" {
  source = "./modules/keypair"
  count  = var.create_key_pair ? 1 : 0

  name_prefix = local.name_prefix
  key_path    = var.key_path
  tags        = local.common_tags
}

# Security Module (optional - can use existing security group)
module "security" {
  source = "./modules/security"
  count  = var.create_security_group ? 1 : 0

  name_prefix      = local.name_prefix
  allowed_ssh_cidr = var.allowed_ssh_cidr
  app_port         = var.app_port
  tags             = local.common_tags
}

locals {
  # Use created or existing security group
  security_group_ids = var.create_security_group ? [module.security[0].security_group_id] : [var.security_group_id]
  # Use created key or existing (empty string = no SSH key)
  key_name = var.create_key_pair ? module.keypair[0].key_name : var.key_name
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  name_prefix        = local.name_prefix
  instance_type      = var.instance_type
  key_name           = local.key_name != "" ? local.key_name : null
  security_group_ids = local.security_group_ids
  volume_size        = var.volume_size
  repo_url           = var.repo_url
  
  # App configuration
  auto_start       = var.auto_start
  db_root_password = var.db_root_password
  db_name          = var.db_name
  db_user          = var.db_user
  db_password      = var.db_password
  frontend_port    = var.frontend_port
  backend_port     = var.app_port
  
  tags = local.common_tags
}
