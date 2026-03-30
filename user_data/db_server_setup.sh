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

# 5. Allow connections from your Web Servers (The "Logic" part)
# By default, Postgres only listens to 'localhost'. We change it to '*' 
# so it listens for the Web Server's requests.
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /varlib/pgsql/data/postgresql.conf

# 6. Trust connections from the VPC CIDR (10.0.0.0/16)
echo "host    all             all             10.0.0.0/16            md5" | sudo tee -a /var/lib/pgsql/data/pg_hba.conf

# 7. Restart to apply changes
sudo systemctl restart postgresql