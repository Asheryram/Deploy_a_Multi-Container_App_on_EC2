# Deploy a Multi-Container App on EC2 (Node.js + MySQL)

A simple **Timesheet API** with full CRUD operations.

## Contents
- [docker-compose.yml](docker-compose.yml)
- [web/app.js](web/app.js)
- [web/package.json](web/package.json)
- [web/Dockerfile](web/Dockerfile)
- [db/init.sql](db/init.sql)
- [.env.example](.env.example)

## API Endpoints

| Method | Endpoint       | Description              |
|--------|----------------|--------------------------|
| GET    | `/`            | Health check             |
| GET    | `/entries`     | List all timesheet entries |
| POST   | `/entries`     | Add a new entry          |
| GET    | `/entries/:id` | Get a single entry       |
| PUT    | `/entries/:id` | Update an entry          |
| DELETE | `/entries/:id` | Delete an entry          |

### Sample POST body
```json
{
  "employee_name": "Alice",
  "date": "2026-02-06",
  "hours_worked": 8,
  "description": "Backend development"
}
```

## Quick Local Run

```bash
cp .env.example .env   # edit with real values
docker compose up --build -d
curl http://localhost:5000
curl http://localhost:5000/entries
docker compose down --volumes
```

## EC2 Deployment with Terraform

### Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- AWS CLI configured with credentials (`aws configure`)
- An existing EC2 Key Pair in your AWS account

### Deploy Infrastructure

```bash
cd terraform

# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your key_name, repo_url, and optionally your IP for SSH

# Initialize and apply
terraform init
terraform plan
terraform apply
```

Terraform will output:
- `public_ip` – EC2 public IP
- `app_url` – URL to access the API
- `ssh_command` – SSH command template

### Start the App on EC2

```bash
# SSH into the instance (wait ~2 min for user_data to complete)
ssh -i <your-key.pem> ec2-user@<public_ip>

# Navigate to app and start
cd app
cp .env.example .env
# Edit .env with secure passwords
docker-compose up --build -d

# Verify
curl http://localhost:5000
curl http://localhost:5000/entries
```

### Cleanup

```bash
# On EC2 first
docker-compose down --volumes

# Then destroy infrastructure
cd terraform
terraform destroy
```

---

## Manual EC2 (Amazon Linux 2) Deployment

1. Provision an EC2 instance (Amazon Linux 2) and open ports 22 and 5000 in the security group.
2. SSH into the instance and install Docker & Compose:

```bash
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

3. Clone this repo, configure `.env`, then run:

```bash
cd Deploy_a_Multi-Container_App_on_EC2
cp .env.example .env
# Edit .env with secure passwords
docker compose up --build -d
curl http://localhost:5000
curl http://localhost:5000/entries
```

4. Cleanup:

```bash
docker compose down --volumes
```

## Evidence
Take screenshots of:
- `curl` output showing API responses
- `docker ps` after `up`
- Screenshot after `down` showing no running containers
# Deploy_a_Multi-Container_App_on_EC2

