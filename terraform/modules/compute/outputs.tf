output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.this.public_ip
}

output "public_dns" {
  description = "Public DNS"
  value       = aws_instance.this.public_dns
}

output "ami_id" {
  description = "AMI ID used"
  value       = data.aws_ami.amazon_linux.id
}
