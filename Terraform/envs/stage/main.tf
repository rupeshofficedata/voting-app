provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5"

  name = "stage-vpc"
  cidr = "10.110.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.110.1.0/24", "10.110.3.0/24"]
  private_subnets = ["10.110.2.0/24", "10.110.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true   # stage = cost optimized

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Environment = "stage"
    Owner       = "rupesh"
    Terraform   = "true"
  }
  public_subnet_tags = {
    Tier = "stage_public"
  }

  private_subnet_tags = {
    Tier = "stage_private"
  }
}
