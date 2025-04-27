output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "EC2 private IP"
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "Primary SG ID"
  value       = aws_security_group.this.id
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.this.name
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.this.name
}

output "subnet_id" {
  description = "Subnet used for the instance"
  value       = local.subnet_id_use
}

output "vpc_id" {
  description = "VPC ID"
  value       = local.vpc_id_use
}

output "ami_id" {
  description = "AMI ID used"
  value       = local.ami_id_use
}
