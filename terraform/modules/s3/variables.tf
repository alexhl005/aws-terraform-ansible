variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "static-files"
}

variable "acl" {
  description = "Access control list for the bucket"
  type        = string
  default     = "private"
}

variable "versioning_enabled" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "attach_policy" {
  description = "Whether to attach a bucket policy"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for the S3 endpoint"
  type        = string
}

variable "route_table_ids" {
  description = "List of route table IDs for the S3 endpoint"
  type        = list(string)
  default     = []
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}