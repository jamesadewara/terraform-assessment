#!/bin/bash
# Update the ec2 instance machine
sudo yum update -y 

# Install Apache 2 :> (httpd)
sudo yum install -y httpd

# Start the Apache service
sudo systemctl start httpd

# Enable Apache to start automatically on every reboot
sudo systemctl enable httpd

# 5. Create a simple HTML page (Requirement 5)
# This grabs the unique Instance ID from AWS metadata to show it works
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
echo "<h1>Hello from TechCorp Web Server</h1><p>Instance ID: $INSTANCE_ID</p>" > /var/www/html/index.index.html