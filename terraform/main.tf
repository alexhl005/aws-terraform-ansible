# terraform/main.tf

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.95.0"
    }
  }
}

# Configuración del provider AWS (puede ser sobrescrita en entornos específicos)
provider "aws" {
  region = "us-east-1"  # Región por defecto

  default_tags {
    tags = {
      Project     = "Ecommerce"
      ManagedBy   = "Terraform"
      Environment = "Global"
    }
  }
}