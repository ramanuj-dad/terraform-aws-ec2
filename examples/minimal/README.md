# terraform-aws-ec2

A Terraform module to launch an EC2 instance with minimal inputs and optional connectivity patterns (RDS egress, S3 access, ALB ingress).

---

## Overview

This module will:

- Generate or accept a `name_prefix` for all resources
- Pick an existing subnet (or the first default-VPC subnet)
- Auto-select an Amazon Linux 2 AMI (unless overridden)
- Create an IAM role/profile (with optional S3 bucket policy)
- Configure a security group (SSH, app port, optional RDS/S3/ALB rules)
- Launch the EC2 instance

---

## Usage Examples

### 1. Minimal (no args)

```hcl
provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source = "github.com/ramanuj-dad/terraform-aws-ec2"
}
```

## Requirements

| Name      | Version  |
|-----------|----------|
| Terraform | >= 1.6.0 |
| aws       | ~> 5.0   |
| random    | ~> 3.0   |

---

## Providers

| Name   | Version |
|--------|---------|
| aws    | ~> 5.0  |
| random | ~> 3.0  |

---

## Inputs

| Name                       | Description                                                              | Type           | Default                                          |
|----------------------------|--------------------------------------------------------------------------|----------------|--------------------------------------------------|
| `subnet_id`                | Existing subnet ID; null to auto-select a default-VPC subnet.            | `string`       | `null`                                           |
| `name_prefix`              | Optional name prefix; null to generate an 8-character random string.     | `string`       | `null`                                           |
| `instance_type`            | EC2 instance type                                                        | `string`       | `"t3.micro"`                                     |
| `ami_id`                   | Explicit AMI ID; null to auto-select Amazon Linux 2.                     | `string`       | `null`                                           |
| `ami_name_pattern`         | AMI name filter pattern                                                  | `string`       | `"amzn2-ami-hvm-*-x86_64-gp2"`                  |
| `ami_architecture`         | Architecture filter                                                      | `string`       | `"x86_64"`                                      |
| `ami_root_device_type`     | Root device type filter                                                  | `string`       | `"ebs"`                                         |
| `ami_virtualization_type`  | Virtualization type filter                                               | `string`       | `"hvm"`                                         |
| `ami_owners`               | List of AMI owner IDs                                                    | `list(string)` | `["137112412989"]`                              |
| `ssh_cidr_blocks`          | CIDRs allowed SSH access                                                  | `list(string)` | `["0.0.0.0/0"]`                                 |
| `app_port`                 | Application port to open                                                  | `number`       | `80`                                            |
| `additional_security_group_ids` | Extra security group IDs to attach                                     | `list(string)` | `[]`                                            |
| `enable_alb_registration`  | Whether to allow ALB SG ingress on `app_port`                             | `bool`         | `false`                                         |
| `alb_security_group_id`    | ALB security group ID (required if `enable_alb_registration=true`)        | `string`       | `null`                                          |
| `enable_rds_integration`   | Whether to allow egress to an RDS security group                          | `bool`         | `false`                                         |
| `rds_security_group_id`    | RDS security group ID (required if `enable_rds_integration=true`)         | `string`       | `null`                                          |
| `enable_s3_integration`    | Whether to attach an S3 access policy to the instance role                | `bool`         | `false`                                         |
| `s3_bucket_name`           | S3 bucket name (required if `enable_s3_integration=true`)                 | `string`       | `null`                                          |

---

## Outputs

| Name                    | Description                   |
|-------------------------|-------------------------------|
| `instance_id`           | EC2 instance ID               |
| `private_ip`            | EC2 private IP address        |
| `security_group_id`     | Primary security group ID     |
| `iam_role_name`         | IAM role name                 |
| `instance_profile_name` | IAM instance profile name     |
| `subnet_id`             | Subnet used for the instance  |
| `vpc_id`                | VPC ID                        |
| `ami_id`                | AMI ID used by the instance   |