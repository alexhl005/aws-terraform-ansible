output "bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "Name of the created S3 bucket"
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "ARN of the created S3 bucket"
}

output "vpc_endpoint_id" {
  value       = aws_vpc_endpoint.s3.id
  description = "ID of the VPC endpoint for S3"
}