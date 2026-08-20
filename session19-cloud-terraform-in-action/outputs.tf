output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web_sg.id
}

output "ec2_public_ip" {
  description = "Public IP address of the deployed web server"
  value       = aws_instance.web.public_ip
}

output "s3_bucket_name" {
  description = "Name of the created S3 storage bucket"
  value       = aws_s3_bucket.app_storage.id
}
