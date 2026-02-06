# Generate RSA private key
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair using the generated public key
resource "aws_key_pair" "this" {
  key_name   = "${var.name_prefix}-key"
  public_key = tls_private_key.this.public_key_openssh

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-key"
  })
}

# Save private key to local file
resource "local_file" "private_key" {
  content         = tls_private_key.this.private_key_pem
  filename        = "${var.key_path}/${var.name_prefix}-key.pem"
  file_permission = "0400"
}

# Save public key to local file (optional, for reference)
resource "local_file" "public_key" {
  content         = tls_private_key.this.public_key_openssh
  filename        = "${var.key_path}/${var.name_prefix}-key.pub"
  file_permission = "0644"
}
