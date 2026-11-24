terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. HUB VPC (Shared Services & Bastion)
resource "aws_vpc" "hub_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = { Name = "hub-management-vpc" }
}

resource "aws_subnet" "hub_public_subnet" {
  vpc_id                  = aws_vpc.hub_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags                    = { Name = "hub-public-subnet" }
}

# 2. SPOKE VPCs (Isolated QA & Production Workloads)
resource "aws_vpc" "spoke_qa_vpc" {
  cidr_block = "10.1.0.0/16"
  tags       = { Name = "spoke-qa-vpc" }
}

resource "aws_vpc" "spoke_prod_vpc" {
  cidr_block = "10.2.0.0/16"
  tags       = { Name = "spoke-prod-vpc" }
}

# 3. VPC Peering (Hub <-> Spokes, without direct Spoke-to-Spoke routing)
resource "aws_vpc_peering_connection" "hub_to_qa" {
  vpc_id      = aws_vpc.hub_vpc.id
  peer_vpc_id = aws_vpc.spoke_qa_vpc.id
  auto_accept = true
  tags        = { Name = "peering-hub-spoke-qa" }
}

resource "aws_vpc_peering_connection" "hub_to_prod" {
  vpc_id      = aws_vpc.hub_vpc.id
  peer_vpc_id = aws_vpc.spoke_prod_vpc.id
  auto_accept = true
  tags        = { Name = "peering-hub-spoke-prod" }
}

# 4. Security Group & EC2 Bastion Host (Jump Box)
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-ssh-sg"
  description = "Allow SSH inbound only from trusted administrator IP"
  vpc_id      = aws_vpc.hub_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with specific admin IP in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion_host" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.hub_public_subnet.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  tags                   = { Name = "ec2-bastion-jumpbox" }
}