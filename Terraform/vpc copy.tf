terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
#---------------- Variables ----------------
variable "project" {
  default = "rupesh-vpc"
}
# ---------------- VPC ----------------
resource "aws_vpc" "main" {
  cidr_block = "10.100.0.0/16"

  tags = {
    Name        = "main"
    Environment = "dev"
    Owner       = "rupesh"
    project     = var.project
  }
}

# ---------------- Subnets ----------------
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.100.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet-1"
    project     = var.project
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.100.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1"
    project     = var.project
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.100.3.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public-subnet-2"
    project     = var.project
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.100.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-2"
    project     = var.project
  }
}

# ---------------- Internet Gateway ----------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# ---------------- NAT Gateway ----------------
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id   # NAT lives in public1

  tags = {
    Name = "main-natgw"
  }

  depends_on = [aws_internet_gateway.igw]
}

# ---------------- Route Tables ----------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "private-rt"
  }
}

# ---------------- Associations ----------------
resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public2_assoc" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private1_assoc" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private2_assoc" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private_rt.id
}

# ---------------- Security Group ----------------
resource "aws_security_group" "Bastion_SG" {
  name        = "Bastion_SG"
  description = "Security group for Bastion host"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "Bastion_SG"
    project     = var.project
  }
  ingress {
    description      = "SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  egress {
    description      = "All outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
}
}

# ---------------- Key Pair ----------------
resource "aws_key_pair" "Bastion_Key" {
  key_name   = "Bastion_Key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# ---------------- Bastion Host ----------------
resource "aws_instance" "Bastion_Host" {
  ami                         = "ami-0ecb62995f68bb549" # ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20251022
  subnet_id                   = aws_subnet.public1.id
  vpc_security_group_ids      = [aws_security_group.Bastion_SG.id]
  key_name                    = aws_key_pair.Bastion_Key.key_name
  instance_type               = "t3.micro"
  associate_public_ip_address = true

  tags = {
    Name = "Bastion_Host"
    project     = var.project
  }
}

# ---------------- Outputs ----------------
output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_subnet_ids" {
  value = [aws_subnet.public1.id, aws_subnet.public2.id]
}
output "private_subnet_ids" {
  value = [aws_subnet.private1.id, aws_subnet.private2.id]
}
output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}
output "nat_gateway_id" {
  value = aws_nat_gateway.natgw.id
}
output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}
output "private_route_table_id" {
  value = aws_route_table.private_rt.id
}
output "bastion_host_public_ip" {
  value = aws_instance.Bastion_Host.public_ip
}
output "bastion_host_private_ip" {
  value = aws_instance.Bastion_Host.private_ip
}

