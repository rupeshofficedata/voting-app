terraform {
  backend "s3" {
    bucket  = "rupesh-terraform-state-dev"
    key     = "stage/network/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
