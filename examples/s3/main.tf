provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source                = "../../"
  enable_s3_integration = true
  s3_bucket_name        = "my-app-bucket"
}
