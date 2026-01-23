# Outputs for AWS Config resources

output "config_bucket_name" {
  description = "Name of the S3 bucket for Config delivery"
  value       = aws_s3_bucket.config_bucket.id
}

output "config_bucket_arn" {
  description = "ARN of the S3 bucket for Config delivery"
  value       = aws_s3_bucket.config_bucket.arn
}

output "config_role_arn" {
  description = "ARN of the IAM role used by AWS Config"
  value       = aws_iam_role.config_role.arn
}

output "config_recorder_name" {
  description = "Name of the AWS Config recorder"
  value       = aws_config_configuration_recorder.config_recorder.name
}

output "config_recorder_status" {
  description = "Status of the AWS Config recorder"
  value       = aws_config_configuration_recorder_status.config_recorder_status.is_enabled
}

output "config_delivery_channel_name" {
  description = "Name of the AWS Config delivery channel"
  value       = aws_config_delivery_channel.config_delivery_channel.name
}
