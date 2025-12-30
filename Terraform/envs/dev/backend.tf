terraform {
  backend "s3" {
    bucket  = "rupesh-terraform-state-dev"
    key     = "dev/network/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
