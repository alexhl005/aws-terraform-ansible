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

  bastion_allowed_cidr = "185.118.190.153/32"
  vpc_cidr             = module.vpc.vpc_cidr 
}

module "rds" {
  source = "../../modules/rds"

  environment           = "dev"
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_rds_subnet_ids
  db_username           = "admin_dev"
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
#      Env     = "dev"
#   }
# }

module "elb" {
  source = "../../modules/elb"
  
  environment         = "dev"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.dmz_subnet_ids
  #certificate_arn     = module.cert.certificate_arn
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
  description = "Endpoint de la base de datos Postgres"
  value       = aws_db_instance.main.address
}

#output "rds_endpoint" {
#  value = aws_rds_cluster.main.endpoint
#}
#
#output "reader_endpoint" {
#  value = aws_rds_cluster.main.reader_endpoint
#}

output "instance_ids" {
  value = aws_instance.web[*].id
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}

output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "IP pública del bastión SSH"
}

output "bucket_name" {
  value       = aws_s3_bucket.backup_bucket.bucket
  description = "Name of the created S3 bucket"
}

output "bucket_arn" {
  value       = aws_s3_bucket.backup_bucket.arn
  description = "ARN of the created S3 bucket"
}

output "vpc_endpoint_id" {
  value       = aws_vpc_endpoint.s3.id
  description = "ID of the VPC endpoint for S3"
}

variable "route_table_id" {
  description = "ID de la tabla de rutas para el endpoint S3"
  type        = string
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "dmz_subnet_ids" {
  value = aws_subnet.dmz[*].id
}

output "dmz_subnet_id" {
  value = aws_subnet.dmz[0].id
}

output "private_ec2_subnet_ids" {
  value = aws_subnet.private_ec2[*].id
}

output "private_rds_subnet_ids" {
  value = aws_subnet.private_rds[*].id
}

output "route_table_id" {
  description = "ID de la tabla de rutas principal"
  value       = aws_route_table.main.id
}