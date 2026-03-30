output "vpc_id" {
  value       = aws_vpc.techcorp_vpc.id
  description = "Display the Techcorp VPC ID"
}

output "load_balancer_dns_name" {
  value       = aws_lb.techcorp_alb.dns_name
  description = "The DNS from the load balancer"
}

output "bastion_public_ip" {
  value       = aws_instance.techcorp_bastion.public_ip
  description = "Will need the ip4 public address for the ssh to the vastion host"
}

output "web_server_1_private_ip" {
  value       = aws_instance.techcorp_web_server_1.private_ip
  description = "The private IP for the 1st web server"
}

output "web_server_2_private_ip" {
  value       = aws_instance.techcorp_web_server_2.private_ip
  description = "The private IP for the 2nd web server"
}