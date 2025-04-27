provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source                   = "../../"

  enable_rds_integration   = true
  rds_security_group_id    = "sg-0123456789abcdef0"

  enable_s3_integration    = true
  s3_bucket_name           = "my-app-bucket"

  enable_alb_registration  = true
  alb_security_group_id    = "sg-0abcdef1234567890"
}
