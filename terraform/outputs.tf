output "instance_id" {
  description = "EC2 instance ID"
  value       = module.compute.instance_id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.compute.public_ip
}

output "public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = module.compute.public_dns
}

output "frontend_url" {
  description = "URL to access the Frontend"
  value       = "http://${module.compute.public_ip}:3000"
}

output "api_url" {
  description = "URL to access the Backend API"
  value       = "http://${module.compute.public_ip}:${var.app_port}"
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = var.create_key_pair ? "ssh -i ${module.keypair[0].private_key_path} ec2-user@${module.compute.public_ip}" : "ssh -i <your-key.pem> ec2-user@${module.compute.public_ip}"
}

output "private_key_path" {
  description = "Path to the generated private key file"
  value       = var.create_key_pair ? module.keypair[0].private_key_path : "N/A - using existing key"
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.security.security_group_id
}
