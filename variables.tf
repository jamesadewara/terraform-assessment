# My current ip address
variable "my_cur_ip" {
  description = "My Ip Address"
  type        = string
}

variable "aws_region"{
    type = string
    description = "Aws Region used for the Infrastructure"
    default = "us-east-1"
}

variable "aws_instance_type"{
    type = string
    description = "The ec2 instance type to use for the web servers"
default = "t3.micro"
}

variable "aws_db_instance_type"{
    type = string
    description = "The db instance type to use for the database server"
    default ="t3.small"
}

variable "aws_key_pair_name"{
    type = string
    description = "the key pair used for the ec2 instnaces"
    default = "techcorp-web-key-pair"
}
