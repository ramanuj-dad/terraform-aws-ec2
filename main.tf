#############################################################################
# 0. Random name_prefix if omitted
#############################################################################
resource "random_string" "prefix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

locals {
  name_prefix_use = coalesce(var.name_prefix, random_string.prefix.result)
}

#############################################################################
# 1. VPC & SUBNET LOOKUP
#############################################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "provided" {
  count = var.subnet_id != null ? 1 : 0
  id    = var.subnet_id
}

data "aws_subnets" "default_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  subnet_id_use = var.subnet_id != null ? var.subnet_id : data.aws_subnets.default_vpc.ids[0]
  vpc_id_use    = var.subnet_id != null ? data.aws_subnet.provided[0].vpc_id : data.aws_vpc.default.id
}

#############################################################################
# 2. AMI SELECTION
#############################################################################
data "aws_ami" "autosel" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }
  filter {
    name   = "architecture"
    values = [var.ami_architecture]
  }
  filter {
    name   = "root-device-type"
    values = [var.ami_root_device_type]
  }
  filter {
    name   = "virtualization-type"
    values = [var.ami_virtualization_type]
  }
}

locals {
  ami_id_use = var.ami_id != null ? var.ami_id : data.aws_ami.autosel[0].id
}

#############################################################################
# 3. IAM ROLE & S3 POLICY
#############################################################################
data "aws_iam_policy_document" "ec2_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${local.name_prefix_use}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust.json
}

resource "aws_iam_instance_profile" "this" {
  name = "${local.name_prefix_use}-profile"
  role = aws_iam_role.this.name
}

data "aws_iam_policy_document" "s3_access" {
  count = var.enable_s3_integration ? 1 : 0

  statement {
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
      "arn:aws:s3:::${var.s3_bucket_name}/*",
    ]
  }
}

resource "aws_iam_role_policy" "s3_access" {
  count  = var.enable_s3_integration ? 1 : 0
  name   = "${local.name_prefix_use}-s3-access"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.s3_access[0].json
}

#############################################################################
# 4. SECURITY GROUP
#############################################################################
resource "aws_security_group" "this" {
  name_prefix = "${local.name_prefix_use}-sg-"
  vpc_id      = local.vpc_id_use
}

resource "aws_security_group_rule" "ssh_in" {
  count             = length(var.ssh_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = var.ssh_cidr_blocks
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "app_in" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = var.app_port
  to_port                  = var.app_port
  security_group_id        = aws_security_group.this.id
  source_security_group_id = var.enable_alb_registration ? var.alb_security_group_id : null
  cidr_blocks              = var.enable_alb_registration ? [] : ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "rds_egress" {
  count                    = var.enable_rds_integration ? 1 : 0
  type                     = "egress"
  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  security_group_id        = aws_security_group.this.id
  source_security_group_id = var.rds_security_group_id
}

resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

#############################################################################
# 5. EC2 INSTANCE
#############################################################################
resource "aws_instance" "this" {
  ami                    = local.ami_id_use
  instance_type          = var.instance_type
  subnet_id              = local.subnet_id_use
  vpc_security_group_ids = concat([aws_security_group.this.id], var.additional_security_group_ids)
  iam_instance_profile   = aws_iam_instance_profile.this.name

  tags = {
    Name   = "${local.name_prefix_use}-ec2"
    Module = "terraform-aws-ec2"
  }
}
