locals {
  aws_availability_zone_1 = "us-east-1a"
  aws_availability_zone_2 = "us-east-1b"
}

# init the cloud provider (aws)
provider "aws" {
  region = var.aws_region
}

# Create vpc
resource "aws_vpc" "techcorp_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "techcorp-vpc"
  }
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# Create the Public subnets
resource "aws_subnet" "techcorp_public_subnet_1" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.aws_availability_zone_1
  tags              = { Name = "techcorp-public-subnet-1" }
}

resource "aws_subnet" "techcorp_public_subnet_2" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = local.aws_availability_zone_2
  tags              = { Name = "techcorp-public-subnet-2" }
}

# Create the Private subnets
resource "aws_subnet" "techcorp_private_subnet_1" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = local.aws_availability_zone_1
  tags              = { Name = "techcorp-private-subnet-1" }
}

resource "aws_subnet" "techcorp_private_subnet_2" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = local.aws_availability_zone_2
  tags              = { Name = "techcorp-private-subnet-2" }
}

# Create the IGW (Internet Gateway for the public subnets)
resource "aws_internet_gateway" "techcorp_igw" {
  vpc_id = aws_vpc.techcorp_vpc.id
  tags   = { Name = "techcorp-igw" }
}


# Create the NAT Gateway and its resources e.g. Elastip IP for the private subnets
resource "aws_eip" "techcorp_nat_eip" {
  domain = "vpc"
  tags   = { Name = "techcorp-nat-eip" }
}

resource "aws_nat_gateway" "techcorp_nat_gateway" {
  allocation_id = aws_eip.techcorp_nat_eip.id
  subnet_id     = aws_subnet.techcorp_public_subnet_1.id

  tags = {
    Name = "techcorp-nat-gateway"
  }

  depends_on = [aws_internet_gateway.techcorp_igw]
}

# Create the Public and Private route table, associate them and configure the routes

# For the Public Route Table and its configurations
resource "aws_route_table" "techcorp_public_route_table" {
  vpc_id = aws_vpc.techcorp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.techcorp_igw.id
  }

  tags = { Name = "techcorp-public-route-table" }
}

resource "aws_route_table_association" "techcorp_public_route_table_association_subnet_1" {
  subnet_id      = aws_subnet.techcorp_public_subnet_1.id
  route_table_id = aws_route_table.techcorp_public_route_table.id
}

resource "aws_route_table_association" "techcorp_public_route_table_association_subnet_2" {
  subnet_id      = aws_subnet.techcorp_public_subnet_2.id
  route_table_id = aws_route_table.techcorp_public_route_table.id
}


# For the Private Route Table and its configurations
resource "aws_route_table" "techcorp_private_route_table" {
  vpc_id = aws_vpc.techcorp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.techcorp_nat_gateway.id
  }

  tags = { Name = "techcorp-private-route-table" }
}

resource "aws_route_table_association" "techcorp_private_route_table_association_subnet_1" {
  subnet_id      = aws_subnet.techcorp_private_subnet_1.id
  route_table_id = aws_route_table.techcorp_private_route_table.id
}

resource "aws_route_table_association" "techcorp_private_route_table_association_subnet_2" {
  subnet_id      = aws_subnet.techcorp_private_subnet_2.id
  route_table_id = aws_route_table.techcorp_private_route_table.id
}

# Create the Security Group for Web Security, ALB, Bastion & Database

# Web Security Group
resource "aws_security_group" "techcorp_web_sg" {
  name        = "techcorp-web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.techcorp_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = [aws_security_group.techcorp_bastion_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "TCP"
    security_groups = [aws_security_group.techcorp_alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Bastion Security Group
resource "aws_security_group" "techcorp_bastion_sg" {
  name        = "techcorp-bastion-sg"
  description = "Security group for bastion servers"
  vpc_id      = aws_vpc.techcorp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [var.my_cur_ip]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application Load Balancer Security Group
resource "aws_security_group" "techcorp_alb_sg" {
  name        = "techcorp-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.techcorp_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database Security Group
resource "aws_security_group" "techcorp_db_sg" {
  name        = "techcorp-db-sg"
  description = "Security group for postgersql db"
  vpc_id      = aws_vpc.techcorp_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = [aws_security_group.techcorp_bastion_sg.id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "TCP"
    security_groups = [aws_security_group.techcorp_web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the EC2 Instances for (Bastion, Web Server and the Database)

# Bastion Instance
resource "aws_instance" "techcorp_bastion" {
  ami                         = var.aws_ami_id
  instance_type               = var.aws_instance_type
  subnet_id                   = aws_subnet.techcorp_public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.techcorp_bastion_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "techcorp-bastion"
  }
}

# Create the Web Server Key pair
resource "aws_key_pair" "techcorp_web_key_pair" {
  key_name   = var.aws_key_pair_name
  public_key = file("${path.module}/keys/techcorp-key.pub") # relative path
}


# Web Server Instance 1
resource "aws_instance" "techcorp_web_server_1" {
  ami                    = var.aws_ami_id
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.techcorp_private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.techcorp_web_sg.id]
  key_name               = aws_key_pair.techcorp_web_key_pair.key_name
  user_data              = file("${path.module}/user_data/web_server_setup.sh") # relative path 


  tags = {
    Name = "techcorp-web-server-1"
  }
}

# Web Server Instance 2
resource "aws_instance" "techcorp_web_server_2" {
  ami                    = var.aws_ami_id
  instance_type          = var.aws_instance_type
  subnet_id              = aws_subnet.techcorp_private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.techcorp_web_sg.id]
  key_name               = aws_key_pair.techcorp_web_key_pair.key_name
  user_data              = file("${path.module}/user_data/web_server_setup.sh") # relative path 

  tags = {
    Name = "techcorp-web-server-2"
  }
}

# Database Server Instance 2
resource "aws_instance" "techcorp_db_server" {
  ami                    = var.aws_ami_id
  instance_type          = var.aws_db_instance_type
  subnet_id              = aws_subnet.techcorp_private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.techcorp_db_sg.id]

  user_data = file("${path.module}/user_data/web_server_setup.sh") # relative path 

  tags = {
    Name = "techcorp-db-server"
  }
}

# Create the Application Load Balancer and its resources
resource "aws_lb" "techcorp_alb" {
  name               = "techcorp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.techcorp_alb_sg.id]
  subnets            = [aws_subnet.techcorp_public_subnet_1.id, aws_subnet.techcorp_public_subnet_2.id]
}

# Target group
resource "aws_lb_target_group" "techcorp_alb_target_group" {
  name     = "techcorp-alb-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.techcorp_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Listeners
resource "aws_lb_listener" "web_listener" {
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.techcorp_alb_target_group.arn
  }

  load_balancer_arn = aws_lb.techcorp_alb.arn
  port              = 80
  protocol          = "HTTP"
}

# Connect the Private Web servers to ALB
resource "aws_lb_target_group_attachment" "techcorp_web_server_1_attachment" {
  target_id        = aws_instance.techcorp_web_server_1.id
  target_group_arn = aws_lb_target_group.techcorp_alb_target_group.arn
  port             = 80
}

resource "aws_lb_target_group_attachment" "techcorp_web_server_2_attachment" {
  target_id        = aws_instance.techcorp_web_server_2.id
  target_group_arn = aws_lb_target_group.techcorp_alb_target_group.arn
  port             = 80
}