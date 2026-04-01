# TechCorp Cloud Infrastructure Assessment

This repository contains a Terraform configuration for a highly available, three-tier web application architecture on AWS. It features secure network isolation, load balancing, and a bastion host for administrative access.

## 🏗 Architecture Overview
- **VPC:** Custom VPC with Public and Private subnets across two Availability Zones.
- **Security:** Ingress/Egress rules restricted by Security Groups (Bastion, Web, and Database tiers).
- **Compute:** EC2 instances for Bastion, Web Servers (Apache), and Database (PostgreSQL).
- **Networking:** Internet Gateway for public access and NAT Gateway for private subnet internet egress.
- **Traffic Management:** Application Load Balancer (ALB) distributing traffic to web servers with health checks.

## Getting Started

### 1. Prerequisites
- Terraform Export variable names for AWS Cloud [terraform.tfvars.example].
- Terraform installed.
- SSH client.

### 2. Clone the Repository
```bash
git clone https://github.com/jamesadewara/month-one-assessments.git
cd month-one-assessments
```

### 3. Generate SSH Keys
Generate a unique key pair to access the instances securely.
```bash
ssh-keygen -t rsa -b 4096 -f ./keys/techcorp-key
```

### 4. Configuration
export to terminal
```bash
# AWS_ACCESS_KEY_ID="your_access_key_id"
# AWS_SECRET_ACCESS_KEY="your_secret_access_key"
```

## 🛠 Deployment Steps

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Format & Validate:**
   ```bash
   terraform fmt
   terraform validate
   ```

3. **Plan & Apply:**
   ```bash
   echo "$(curl -s ifconfig.me)/32" # for current ip 
   terraform plan
   terraform apply
   ```

## 🔐 Accessing the Infrastructure

This setup uses **SSH Agent Forwarding** to ensure your private key never leaves your local machine.

1. **Add your key to the SSH agent:**
   ```bash
   chmod 600 ./keys/techcorp-key
   chmod 644 ./keys/techcorp-key.pub
   eval `ssh-agent -s`
   ssh-add ./keys/techcorp-key
   ```

2. **Connect to the Bastion Host:**
   ```bash
   ssh -A ec2-user@<BASTION-PUBLIC-IP>
   ```

3. **Jump to Private Servers:**
   From the Bastion terminal, you can access the internal servers using their private IPs:
   ```bash
   ssh ec2-user@<WEB-SERVER-1-PRIVATE-IP>
   ssh ec2-user@<DB-SERVER-PRIVATE-IP>
   ```

4. **Connect to the Postgres Instance on the DB Server**
```bash
psql -U postgres
```

## 🧹 Cleanup
To avoid ongoing AWS costs, destroy the infrastructure once the assessment is complete:
```bash
terraform destroy -auto-approve
```