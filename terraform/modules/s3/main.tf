resource "aws_s3_bucket" "backup_bucket" {
  bucket = "${var.environment}-backup-bucket"
  
  tags = {
    Environment = var.environment
    Name        = "${var.environment}-backup-bucket"
  }
}

resource "aws_s3_bucket_acl" "backup_bucket" {
  bucket = aws_s3_bucket.backup_bucket.id
  acl    = var.acl
}

resource "aws_s3_bucket_versioning" "backup_bucket" {
  bucket = aws_s3_bucket.backup_bucket.id
  
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup_bucket" {
  bucket = aws_s3_bucket.backup_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "backup_bucket" {
  count = var.attach_policy ? 1 : 0

  bucket = aws_s3_bucket.backup_bucket.id
  policy = data.aws_iam_policy_document.s3_policy[0].json
}

data "aws_iam_policy_document" "s3_policy" {
  count = var.attach_policy ? 1 : 0

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.backup_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.route_table_id]

  tags = {
    Name = "${var.environment}-s3-endpoint"
    Environment = var.environment
  }
}
