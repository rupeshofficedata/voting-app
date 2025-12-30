terraform {
  backend "s3" {
    bucket  = "rupesh-terraform-state-dev"
    key     = "prod/network/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true

    # PRO TIP:
    # Keep prod state isolated by key path.
    # Never reuse the same key across environments.
    lifecycle {
    prevent_destroy = true
  }
  }
}
