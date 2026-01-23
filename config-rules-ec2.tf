# AWS Config Rules for EC2 and EBS

resource "aws_config_config_rule" "ec2_no_amazon_key_pair" {
  name = "ec2-no-amazon-key-pair"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "EC2_NO_AMAZON_KEY_PAIR"
  }

  scope {
    compliance_resource_types = ["AWS::EC2::Instance"]
  }
  depends_on = local.config_rule_depends_on
}

resource "aws_config_config_rule" "ec2_instance_detailed_monitoring_enabled" {
  name = "ec2-instance-detailed-monitoring-enabled"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "EC2_INSTANCE_DETAILED_MONITORING_ENABLED"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::Instance"]
  }
  depends_on = local.config_rule_depends_on
}

resource "aws_config_config_rule" "ec2_ebs_encryption_by_default" {
  name = "ec2-ebs-encryption-by-default"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "EC2_EBS_ENCRYPTION_BY_DEFAULT"
  }
  depends_on = local.config_rule_depends_on
}

resource "aws_config_config_rule" "encrypted_volumes" {
  name = "encrypted-volumes"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "ENCRYPTED_VOLUMES"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::Volume"]
  }
  depends_on = local.config_rule_depends_on
}

resource "aws_config_config_rule" "ec2_instance_managed_by_ssm" {
  name = "ec2-instance-managed-by-systems-manager"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "EC2_INSTANCE_MANAGED_BY_SSM"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::Instance"]
  }
  depends_on = local.config_rule_depends_on
}
