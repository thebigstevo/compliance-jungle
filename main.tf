# AWS S3 bucket for Config delivery
resource "aws_s3_bucket" "config_bucket" {
  bucket = "compliance-jungle-config-monitoring-bucket"
}

resource "aws_s3_bucket_versioning" "config_bucket_versioning" {
  bucket = aws_s3_bucket.config_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
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
        Resource = aws_s3_bucket.config_bucket.arn
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# IAM role for AWS Config
resource "aws_iam_role" "config_role" {
  name = "AWSConfigRole"

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

resource "aws_iam_role_policy" "config_policy" {
  role = aws_iam_role.config_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:*",
          "sns:*",
          "config:*",
          "s3:GetBucketAcl",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "*"
      }
    ]
  })
}

# Configuration Recorder
resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = false
    resource_types = [
      "AWS::S3::Bucket",
      "AWS::EC2::Instance",
    ]
  }

  
}

# Delivery Channel
resource "aws_config_delivery_channel" "config_delivery_channel" {
  name           = "config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket

  depends_on = [
    aws_config_configuration_recorder.config_recorder,
    aws_s3_bucket_policy.config_bucket_policy,
    aws_s3_bucket_versioning.config_bucket_versioning
  ]
}

resource "aws_config_configuration_recorder_status" "config_recorder_status" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config_delivery_channel]
}

# Config Rule for S3 Bucket Encryption
resource "aws_config_config_rule" "s3_bucket_encryption" {
  name = "s3-bucket-encryption"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

# Config Rule for EC2 no EC2-No-Amazon-Key-Pair
resource "aws_config_config_rule" "ec2_no_amazon_key_pair" {
  name = "ec2-no-amazon-key-pair"

  source {
    owner             = "AWS"
    source_identifier = "EC2_NO_AMAZON_KEY_PAIR"
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}
