# AWS S3 bucket for Config delivery
resource "aws_s3_bucket" "config_bucket" {
  bucket = "aws-config-monitoring-bucket"
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
          "s3:PutObject",
          "sns:Publish",
          "config:Put*",
          "config:Start*",
          "config:Stop*"
        ],
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
}

# Config Rule for S3 Bucket Encryption
resource "aws_config_config_rule" "s3_bucket_encryption" {
  name = "s3-bucket-encryption"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }
}

# # Config Rule for S3 Bucket Encryption
# resource "aws_config_config_rule" "ec2_no_amazon_key_pair" {
#   name = "ec2-no-amazon-key-pair"

#   source {
#     owner             = "AWS"
#     source_identifier = "EC2_NO_AMAZON_KEY_PAIR"
#   }
# }