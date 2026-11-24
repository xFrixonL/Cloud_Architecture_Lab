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

resource "aws_db_instance" "rehosted_postgres" {
  identifier             = "ecodump-rehosted-rds"
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  db_name                = "municipal_cloud_db"
  username               = "rds_admin"
  password               = "ChangeMeInSecretsManager123!"
  publicly_accessible    = false
  skip_final_snapshot    = true
  backup_retention_period = 7

  tags = {
    Strategy = "Lift-and-Shift"
    Source   = "On-Premise-Datacenter"
  }
}