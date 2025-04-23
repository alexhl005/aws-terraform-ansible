terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  environment               = "dev"
  vpc_cidr                  = "10.0.0.0/16"
  dmz_subnet_cidr          = "10.0.1.0/24"
  private_ec2_subnet_cidr  = "10.0.2.0/24"
  private_rds_subnet_cidr  = "10.0.3.0/24"
  azs                       = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

module "ec2" {
  source = "../../modules/ec2"

  environment        = "dev"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  ami_id             = "ami-0f9de6e2d2f067fca"  # Ubuntu 22.04
  instance_type      = "t2.micro"
  instance_count     = 3
  ssh_allowed_cidrs  = ["10.0.0.0/16"]
  key_name           = "vockey"
}

module "rds" {
  source = "../../modules/rds"

  environment          = "dev"
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  db_username          = "admin_dev"
  db_password          = "Root1234$"
  instance_class       = "db.c6gd.medium"
  multi_az             = true
  allowed_cidr_blocks  = module.vpc.private_subnet_ids
}

module "elb" {
  source = "../../modules/elb"
  
  environment         = "dev"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids          = module.vpc.dmz_subnet_cidr
  certificate_arn     = "arn:aws:acm:us-east-1:123456789012:certificate/abc123"
}

output "rds_endpoint" {
  value       = module.rds.cluster_endpoint
  description = "Endpoint del cluster RDS"
}

output "ec2_instances" {
  value = module.ec2.instance_ids
}