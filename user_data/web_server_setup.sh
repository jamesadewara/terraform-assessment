#!/bin/bash
# Update the ec2 instance machine
sudo yum update -y 

# Install Apache 2 :> (httpd)
sudo yum install -y httpd

# Start the Apache service
sudo systemctl start httpd

# Enable Apache to start automatically on every reboot
sudo systemctl enable httpd


# Fetch Metadata from the AWS internal service (IMDS)
# We get the unique ID and the internal network IP
# Fetch Metadata using IMDSv2 (Token-based)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

# 5. Create the HTML page for the assessment
# This uses a "Here Document" (cat <<EOF) to make the code clean and readable
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>TechCorp Web Server</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; text-align: center; background-color: #f4f4f9; color: #333; }
        .container { border: 2px solid #0073bb; background-color: white; padding: 40px; display: inline-block; border-radius: 15px; margin-top: 100px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        h1 { color: #0073bb; }
        .info { font-size: 1.2em; margin: 10px 0; }
        .footer { margin-top: 20px; font-size: 0.8em; color: #777; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Hello James Ayomide Adewara</h1>
        <h3>TechCorp Web Application Deployment</h3>
        <hr>
        <div class="info"><strong>Instance ID:</strong> $INSTANCE_ID</div>
        <div class="info"><strong>Private IP:</strong> $PRIVATE_IP</div>
        <div class="footer">Infrastructure Provisioned via Terraform</div>
    </div>
</body>
</html>
EOF