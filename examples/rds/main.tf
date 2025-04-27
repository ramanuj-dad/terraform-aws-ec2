provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source                   = "../../"
  enable_rds_integration   = true
  rds_security_group_id    = "sg-0123456789abcdef0"
}
