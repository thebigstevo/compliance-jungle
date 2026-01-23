# Local values for AWS Config

locals {
  # Common tags for all resources
  common_tags = {
    Project     = "OpenEMR-Compliance"
    ManagedBy   = "Terraform"
    Environment = var.environment
  }
  
  # AWS managed rule owner
  aws_rule_owner = "AWS"
}
