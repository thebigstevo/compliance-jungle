variable "region" {
  type        = string
  default     = "us-west-2"
  description = "AWS region for Config deployment"
}

variable "environment" {
  type        = string
  default     = "production"
  description = "Environment name (e.g., production, staging, development)"
}

variable "config_bucket_name" {
  type        = string
  default     = "compliance-config-monitoring-bucket-25"
  description = "S3 bucket name for AWS Config delivery"
}

variable "config_role_name" {
  type        = string
  default     = "AWSConfigRole"
  description = "IAM role name for AWS Config"
}

variable "config_recorder_name" {
  type        = string
  default     = "config-recorder"
  description = "Name of the AWS Config recorder"
}

variable "config_delivery_channel_name" {
  type        = string
  default     = "config-delivery-channel"
  description = "Name of the AWS Config delivery channel"
}

variable "enable_config_recorder" {
  type        = bool
  default     = true
  description = "Enable or disable the Config recorder"
}

variable "include_global_resource_types" {
  type        = bool
  default     = true
  description = "Include global resources like S3 and IAM in Config recording"
}

variable "s3_encryption_algorithm" {
  type        = string
  default     = "AES256"
  description = "S3 server-side encryption algorithm (AES256 or aws:kms)"
  validation {
    condition     = contains(["AES256", "aws:kms"], var.s3_encryption_algorithm)
    error_message = "S3 encryption algorithm must be either AES256 or aws:kms."
  }
}

variable "blocked_ports" {
  type        = list(string)
  default     = ["20", "21", "3389", "3306", "5432"]
  description = "List of ports to block in security group rules"
}

variable "resource_tag_key" {
  type        = string
  default     = "Name"
  description = "Tag key to filter resources for Config evaluation"
}

variable "resource_tag_value" {
  type        = string
  default     = "openemr"
  description = "Tag value to filter resources for Config evaluation (case-insensitive contains)"
}