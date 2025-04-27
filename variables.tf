###################
# NETWORK
###################
variable "subnet_id" {
  description = <<-EOF
    Existing subnet ID to launch the instance in.
    Leave null to auto-select a default-VPC subnet.
  EOF
  type        = string
  default     = null
}

###################
# NAMING
###################
variable "name_prefix" {
  description = <<-EOF
    Optional prefix for all resource names.
    If null, an 8-character random string is used.
  EOF
  type        = string
  default     = null
}

###################
# INSTANCE BASICS
###################
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

###################
# AMI SELECTION
###################
variable "ami_id" {
  description = "Explicit AMI ID; if null, auto-selects Amazon Linux 2."
  type        = string
  default     = null
}
variable "ami_name_pattern" {
  type    = string
  default = "amzn2-ami-hvm-*-x86_64-gp2"
}
variable "ami_architecture" {
  type    = string
  default = "x86_64"
}
variable "ami_root_device_type" {
  type    = string
  default = "ebs"
}
variable "ami_virtualization_type" {
  type    = string
  default = "hvm"
}
variable "ami_owners" {
  type    = list(string)
  default = ["137112412989"]
}

###################
# SECURITY GROUP
###################
variable "ssh_cidr_blocks" {
  description = "CIDRs allowed to SSH."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
variable "app_port" {
  description = "Application port to open."
  type        = number
  default     = 80
}
variable "additional_security_group_ids" {
  description = "Extra SGs to attach."
  type        = list(string)
  default     = []
}

###################
# OPTIONAL INTEGRATIONS
###################
variable "enable_alb_registration" {
  description = "Allow ALB SG ingress on app_port."
  type        = bool
  default     = false
}
variable "alb_security_group_id" {
  description = "SG ID of the ALB (required if enable_alb_registration=true)."
  type        = string
  default     = null

  validation {
    condition     = var.enable_alb_registration == false || var.alb_security_group_id != null
    error_message = "Must set alb_security_group_id when enable_alb_registration=true."
  }
}

variable "enable_rds_integration" {
  description = "Allow egress to RDS SG."
  type        = bool
  default     = false
}
variable "rds_security_group_id" {
  description = "SG ID of the RDS (required if enable_rds_integration=true)."
  type        = string
  default     = null

  validation {
    condition     = var.enable_rds_integration == false || var.rds_security_group_id != null
    error_message = "Must set rds_security_group_id when enable_rds_integration=true."
  }
}

variable "enable_s3_integration" {
  description = "Attach S3 policy to instance role."
  type        = bool
  default     = false
}
variable "s3_bucket_name" {
  description = "Bucket name (required if enable_s3_integration=true)."
  type        = string
  default     = null

  validation {
    condition     = var.enable_s3_integration == false || var.s3_bucket_name != null
    error_message = "Must set s3_bucket_name when enable_s3_integration=true."
  }
}
