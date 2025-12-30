module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "TFModuleVPC"
  cidr = "10.100.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.100.1.0/24", "10.100.2.0/24"]
  public_subnets  = ["10.100.3.0/24", "10.100.4.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
module "Bastion_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "Bastion-service"
  description = "Bastion security group"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh-service ports"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_rules = [
    "all-all"
  ]
}
module "Bastion_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "Bastion-instance"

  instance_type = "t3.micro"
  key_name      = "user1"
  monitoring    = true
  vpc_security_group_ids = [module.Bastion_sg.security_group_ids]
  subnet_id     =   module.vpc.vpc_id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}