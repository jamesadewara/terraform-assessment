#!/bin/bash
# Update the ec2 system
sudo yum update -y

# Install PostgreSQL 13 (Stable version for Amazon Linux 2)
sudo amazon-linux-extras enable postgresql13
sudo yum install -y postgresql-server

# Initialize the database cluster
sudo postgresql-setup initdb

# Start and Enable PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql