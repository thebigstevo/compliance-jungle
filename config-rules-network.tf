# AWS Config Rules for VPC and Network Security

resource "aws_config_config_rule" "ec2_security_group_ssh_restricted" {
  name = "restricted-ssh"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "INCOMING_SSH_DISABLED"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::SecurityGroup"]
  }
  depends_on = local.config_rule_depends_on
}

resource "aws_config_config_rule" "vpc_flow_logs_enabled" {
  name = "vpc-flow-logs-enabled"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "VPC_FLOW_LOGS_ENABLED"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::VPC"]
  }
  depends_on = local.config_rule_depends_on
}

resource "aws_config_config_rule" "vpc_default_security_group_closed" {
  name = "vpc-default-security-group-closed"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "VPC_DEFAULT_SECURITY_GROUP_CLOSED"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::SecurityGroup"]
  }
  depends_on = local.config_rule_depends_on
}

resource "aws_config_config_rule" "vpc_network_acl_unused_check" {
  name = "vpc-network-acl-unused-check"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "VPC_NETWORK_ACL_UNUSED_CHECK"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::NetworkAcl"]
  }
  depends_on = local.config_rule_depends_on
}

resource "aws_config_config_rule" "restricted_common_ports" {
  name = "restricted-common-ports"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "RESTRICTED_INCOMING_TRAFFIC"
  }
  
  input_parameters = jsonencode({
    blockedPort1 = var.blocked_ports[0]
    blockedPort2 = var.blocked_ports[1]
    blockedPort3 = var.blocked_ports[2]
    blockedPort4 = var.blocked_ports[3]
    blockedPort5 = var.blocked_ports[4]
  })

  scope {
    compliance_resource_types = ["AWS::EC2::SecurityGroup"]
  }
  depends_on = local.config_rule_depends_on
}
