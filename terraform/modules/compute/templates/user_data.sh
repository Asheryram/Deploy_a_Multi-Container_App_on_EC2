#!/bin/bash
set -e

echo "Starting setup..."

# Update system
yum update -y

# Install Docker
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Docker Compose v2
DOCKER_COMPOSE_VERSION="v2.24.0"
curl -SL "https://github.com/docker/compose/releases/download/$${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install git
yum install -y git

# Clone the repository if URL provided
%{ if repo_url != "" ~}
cd /home/ec2-user
git clone ${repo_url} app || echo "Clone failed or repo already exists"
chown -R ec2-user:ec2-user /home/ec2-user/app
%{ endif ~}

echo "Setup complete!" > /home/ec2-user/setup-complete.txt
echo "Docker version: $(docker --version)" >> /home/ec2-user/setup-complete.txt
echo "Docker Compose version: $(docker-compose --version)" >> /home/ec2-user/setup-complete.txt
