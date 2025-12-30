provider "aws" {
  region = "us-east-1"

  # PRO TIP:
  # In production, use a dedicated AWS account.
  # Never share prod credentials with dev/stage.
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5"  # PRO TIP: Pin module versions. Never use "latest".

  name = "prod-vpc"
  cidr = "10.120.0.0/16"

  # PRO TIP:
  # Always use at least 2 AZs in prod for resilience.
  azs = ["us-east-1a", "us-east-1b"]

  public_subnets  = ["10.120.1.0/24", "10.120.3.0/24"]
  private_subnets = ["10.120.2.0/24", "10.120.4.0/24"]

  # PRO TIP:
  # Production should NEVER use a single NAT gateway.
  # One NAT per AZ prevents AZ-level outage impact.
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  # PRO TIP:
  # Always enable DNS in VPCs.
  # Required for EKS, RDS, ALB, and private endpoints.
  enable_dns_support   = true
  enable_dns_hostnames = true

  # PRO TIP:
  # Centralized tagging helps with:
  # - Cost allocation
  # - Security audits
  # - Incident response
  tags = {
    Environment = "prod"
    Owner       = "rupesh"
    Terraform   = "true"
    Criticality = "high"
  }

  # PRO TIP:
  # Explicit subnet tagging is required for:
  # - Kubernetes (EKS)
  # - ALB Ingress Controller
  public_subnet_tags = {
    Tier = "prod_public"
  }

  private_subnet_tags = {
    Tier = "prod_private"
  }
}
