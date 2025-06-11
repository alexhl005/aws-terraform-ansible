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

  environment               = "prod"
  vpc_cidr                  = "10.0.0.0/16"
  dmz_subnet_cidr           = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  private_ec2_subnet_cidr   = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  private_rds_subnet_cidr   = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
  azs                       = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

module "ec2" {
  source = "../../modules/ec2"

  environment        = "prod"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_ec2_subnet_ids
  dmz_subnet_id      = module.vpc.dmz_subnet_id
  ami_id             = "ami-0f9de6e2d2f067fca"  # Ubuntu 22.04
  instance_type      = "t2.micro"
  instance_count     = 3
  ssh_allowed_cidrs  = ["10.0.0.0/16"]
  key_name           = "vockey"

  bastion_allowed_cidr = "185.118.190.153/32"
  vpc_cidr             = module.vpc.vpc_cidr 
}

module "rds" {
  source = "../../modules/rds"

  environment           = "prod"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_rds_subnet_ids
  db_username           = "admin_prod"
  db_password           = "Root1234$"
  instance_class        = "db.m5d.large"
  allocated_storage     = "400"
  multi_az              = false
  ec2_security_group_id = module.ec2.ec2_security_group_id
}

# module "cert" {
#  source = "../../modules/cert"
#
#  domain_name = "2asir.es"
#
#    tags = {
#      Project = "eCommerce"
#      Env     = "prod"
#   }
# }

module "elb" {
  source = "../../modules/elb"
  
  environment         = "prod"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.dmz_subnet_ids
  #certificate_arn     = module.cert.certificate_arn
}

module "s3" {
  source = "../../modules/s3"

  environment      = "prod"
  bucket_name      = "static-files-backup"
  vpc_id           = module.vpc.vpc_id
  route_table_id  = module.vpc.route_table_id
  attach_policy    = true
}

#—— Outputs ——————————————————————————————————————————

output "vpc_id" {
  description = "ID de la VPC"
  value       = module.vpc.vpc_id
}

output "dmz_subnet_ids" {
  description = "IDs de las subnets públicas (DMZ)"
  value       = module.vpc.dmz_subnet_ids
}

output "private_ec2_subnet_ids" {
  description = "IDs de las subnets privadas para EC2"
  value       = module.vpc.private_ec2_subnet_ids
}

output "private_rds_subnet_ids" {
  description = "IDs de las subnets privadas para RDS"
  value       = module.vpc.private_rds_subnet_ids
}

output "instance_ids" {
  description = "IDs de las instancias EC2"
  value       = module.ec2.instance_ids
}

output "ec2_security_group_id" {
  description = "ID del Security Group de EC2"
  value       = module.ec2.ec2_security_group_id
}

output "bastion_public_ip" {
  description = "IP pública del bastión"
  value       = module.ec2.bastion_public_ip
}

output "rds_endpoint" {
  description = "Endpoint de la base de datos Postgres"
  value       = module.rds.db_instance_address
}

output "s3_bucket_name" {
  description = "Nombre del bucket S3"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN del bucket S3"
  value       = module.s3.bucket_arn
}

output "s3_vpc_endpoint_id" {
  description = "ID del endpoint VPC para S3"
  value       = module.s3.vpc_endpoint_id
}

output "elb_dns_name" {
  description = "DNS Name del ELB"
  value       = module.elb.elb_dns_name
}