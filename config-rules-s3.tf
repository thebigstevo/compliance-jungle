# AWS Config Rules for S3

resource "aws_config_config_rule" "s3_bucket_encryption" {
  name = "s3-bucket-encryption"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  scope {
    tag_key   = var.resource_tag_key
    tag_value = var.resource_tag_value
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "s3_bucket_versioning_enabled" {
  name = "s3-bucket-versioning-enabled"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }
  scope {
    tag_key   = var.resource_tag_key
    tag_value = var.resource_tag_value
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name = "s3-bucket-public-read-prohibited"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  scope {
    tag_key   = var.resource_tag_key
    tag_value = var.resource_tag_value
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "s3_bucket_public_write_prohibited" {
  name = "s3-bucket-public-write-prohibited"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }
  scope {
    tag_key   = var.resource_tag_key
    tag_value = var.resource_tag_value
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "s3_bucket_logging_enabled" {
  name = "s3-bucket-logging-enabled"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "S3_BUCKET_LOGGING_ENABLED"
  }
  scope {
    tag_key   = var.resource_tag_key
    tag_value = var.resource_tag_value
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}
