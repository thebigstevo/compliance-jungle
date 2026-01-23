# AWS Config Infrastructure
# S3 bucket, IAM role, Configuration Recorder, and Delivery Channel

# AWS S3 bucket for Config delivery
resource "aws_s3_bucket" "config_bucket" {
  bucket = var.config_bucket_name
}

resource "aws_s3_bucket_versioning" "config_bucket_versioning" {
  bucket = aws_s3_bucket.config_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_bucket_encryption" {
  bucket = aws_s3_bucket.config_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.s3_encryption_algorithm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "config_bucket_public_access_block" {
  bucket = aws_s3_bucket.config_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "config_role" {
  name = var.config_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = aws_s3_bucket.config_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config_bucket.arn
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config_policy_attachment" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_configuration_recorder" "config_recorder" {
  name     = var.config_recorder_name
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = var.include_global_resource_types
  }
}

resource "aws_config_delivery_channel" "config_delivery_channel" {
  name           = var.config_delivery_channel_name
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket

  depends_on = [
    aws_config_configuration_recorder.config_recorder,
    aws_s3_bucket_policy.config_bucket_policy,
    aws_s3_bucket_versioning.config_bucket_versioning
  ]
}

resource "aws_config_configuration_recorder_status" "config_recorder_status" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = var.enable_config_recorder
  depends_on = [aws_config_delivery_channel.config_delivery_channel]
}
