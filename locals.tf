# Local values for AWS Config

locals {
  # Common tags for all resources
  common_tags = {
    Project     = "OpenEMR-Compliance"
    ManagedBy   = "Terraform"
    Environment = var.environment
  }

  # Config rule common settings
  config_rule_depends_on = [aws_config_configuration_recorder.config_recorder]
  
  # AWS managed rule owner
  aws_rule_owner = "AWS"
}
