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
  skip_credentials_validation = true
  skip_metadata_api_check     = true
}

module "vpc" {
  source = "../../modules/vpc"

  environment               = "dev"
  vpc_cidr                  = "10.0.0.0/16"
  dmz_subnet_cidr           = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_ec2_subnet_cidr   = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  private_rds_subnet_cidr   = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
  azs                       = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

module "ec2" {
  source = "../../modules/ec2"

  environment        = "dev"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_ec2_subnet_ids
  dmz_subnet_id      = module.vpc.dmz_subnet_id
  ami_id             = "ami-0f9de6e2d2f067fca"  # Ubuntu 22.04
  instance_type      = "t2.micro"
  instance_count     = 3
  ssh_allowed_cidrs  = ["10.0.0.0/16"]
  key_name           = "vockey"
}

module "rds" {
  source = "../../modules/rds"

  environment           = "dev"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_rds_subnet_ids
  db_username           = "admin_dev"
  db_password           = "Root1234$"
  instance_class        = "db.c6gd.medium"
  multi_az              = true
  ec2_security_group_id = module.ec2.ec2_security_group_id
}

module "cert" {
  source = "../../modules/cert"

  environment       = "dev"
  apache_vhost_name = "2asir.es"
  domain_name       = module.cert.apache_vhost_name

  tags = {
    Project         = "eCommerce"
  }
}

module "elb" {
  source = "../../modules/elb"
  
  environment         = "dev"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.dmz_subnet_ids
  certificate_arn     = module.acm_cert.certificate_arn
}

module "s3" {
  source = "../../modules/s3"

  environment      = "dev"
  bucket_name      = "static-files-backup"
  vpc_id           = module.vpc.vpc_id
  route_table_id  = module.vpc.route_table_id
  attach_policy    = true
}

output "rds_endpoint" {
  value       = module.rds.cluster_endpoint
  description = "Endpoint del cluster RDS"
}

output "ec2_instances" {
  value = module.ec2.instance_ids
}

output "s3_bucket_name" {
  value       = module.s3.bucket_name
  description = "Name of the S3 static files bucket"
}

output "s3_bucket_arn" {
  value       = module.s3.bucket_arn
  description = "ARN of the S3 static files bucket"
}

output "s3_vpc_endpoint_id" {
  value       = module.s3.vpc_endpoint_id
  description = "ID of the VPC endpoint for S3"
}