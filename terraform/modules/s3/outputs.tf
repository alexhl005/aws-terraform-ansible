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
