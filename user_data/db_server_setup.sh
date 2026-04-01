#!/bin/bash
# Update the ec2 system
sudo yum update -y


# Install the software
sudo dnf install -y postgresql15-server

# Initialize the database (Mandatory on first install)
sudo postgresql-setup --initdb

# Start the engine
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Try the connection again
sudo -u postgres psql