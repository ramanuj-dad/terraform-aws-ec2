# terraform-aws-ec2

A reusable Terraform module to launch an EC2 instance with optional connectivity to RDS, S3, and ALBs, using best practices and minimal inputs.

---

## Overview

This module will:

- Pick (or generate) a `name_prefix`
- Select an existing subnet (or the first default-VPC subnet)
- Auto-select an Amazon Linux 2 AMI (unless overridden)
- Create an IAM role/profile (optional S3 access)
- Configure a security group (SSH, app port, RDS egress)
- Launch the EC2 instance

---

## Usage Examples

### Minimal

```hcl
module "ec2" {
  source = "github.com/ramanuj-dad/terraform-aws-ec2"

  # All other inputs are optional
}
```

### With Integrations

```hcl
module "ec2" {
  source = "github.com/ramanuj-dad/terraform-aws-ec2"

  enable_s3_integration  = true
  s3_bucket_name         = "my-app-bucket"

  enable_rds_integration = true
  rds_security_group_id  = "sg-012345abcde"

  enable_alb_registration = true
  alb_security_group_id   = "sg-0fedcba9876"
}
```

---

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.6.0 |
| AWS provider | ~> 5.0 |
| Random provider | ~> 3.0 |

---

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |
| random | ~> 3.0 |

---

## Resources

| Type | Name |
|------|------|
| random_string | prefix |
| aws_vpc | default (data) |
| aws_subnet | provided (data) |
| aws_subnets | default_vpc (data) |
| aws_ami | autosel (data) |
| aws_iam_policy_document | ec2_trust, s3_access (data) |
| aws_iam_role | this |
| aws_iam_instance_profile | this |
| aws_iam_role_policy | s3_access |
| aws_security_group | this |
| aws_security_group_rule | ssh_in, app_in, rds_egress, all_egress |
| aws_instance | this |

---

## Inputs

| Name                      | Description                                                                 | Type         | Default               |
|---------------------------|-----------------------------------------------------------------------------|--------------|-----------------------|
| subnet_id                 | Existing subnet ID; null to auto-select a default-VPC subnet.               | `string`     | `null`                |
| name_prefix               | Optional prefix; null to generate a random 8-character string.              | `string`     | `null`                |
| instance_type             | EC2 instance type                                                           | `string`     | `"t3.micro"`          |
| ami_id                    | Explicit AMI ID; null to auto-select Amazon Linux 2.                         | `string`     | `null`                |
| ami_name_pattern          | AMI name filter pattern                                                     | `string`     | `"amzn2-ami-hvm-*-x86_64-gp2"` |
| ami_architecture          | AMI architecture filter                                                      | `string`     | `"x86_64"`            |
| ami_root_device_type      | AMI root device type filter                                                 | `string`     | `"ebs"`               |
| ami_virtualization_type   | AMI virtualization type filter                                              | `string`     | `"hvm"`               |
| ami_owners                | List of AMI owner IDs                                                       | `list(string)`| `["137112412989"]`    |
| ssh_cidr_blocks           | CIDRs allowed to SSH                                                         | `list(string)`| `["0.0.0.0/0"]`       |
| app_port                  | Application port to open                                                     | `number`     | `80`                  |
| additional_security_group_ids | Extra security group IDs to attach                                     | `list(string)`| `[]`                  |
| enable_alb_registration   | Enable ALB SG ingress rule                                                   | `bool`       | `false`               |
| alb_security_group_id     | ALB security group ID (required if `enable_alb_registration=true`)           | `string`     | `null`                |
| enable_rds_integration    | Enable RDS SG egress rule                                                    | `bool`       | `false`               |
| rds_security_group_id     | RDS security group ID (required if `enable_rds_integration=true`)            | `string`     | `null`                |
| enable_s3_integration     | Enable S3 access policy attachment                                           | `bool`       | `false`               |
| s3_bucket_name            | S3 bucket name (required if `enable_s3_integration=true`)                    | `string`     | `null`                |

---

## Outputs

| Name                  | Description                        |
|-----------------------|------------------------------------|
| instance_id           | EC2 instance ID                    |
| private_ip            | EC2 private IP address             |
| security_group_id     | Security group ID                  |
| iam_role_name         | IAM role name                      |
| instance_profile_name | IAM instance profile name          |
| subnet_id             | Subnet ID used                     |
| vpc_id                | VPC ID                             |
| ami_id                | AMI ID used                        |
```

---