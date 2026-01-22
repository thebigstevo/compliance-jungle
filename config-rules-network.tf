# AWS Config Rules for VPC and Network Security

resource "aws_config_config_rule" "ec2_security_group_ssh_restricted" {
  name = "restricted-ssh"

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::SecurityGroup"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "vpc_flow_logs_enabled" {
  name = "vpc-flow-logs-enabled"

  source {
    owner             = "AWS"
    source_identifier = "VPC_FLOW_LOGS_ENABLED"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::VPC"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "vpc_default_security_group_closed" {
  name = "vpc-default-security-group-closed"

  source {
    owner             = "AWS"
    source_identifier = "VPC_DEFAULT_SECURITY_GROUP_CLOSED"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::SecurityGroup"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "vpc_network_acl_unused_check" {
  name = "vpc-network-acl-unused-check"

  source {
    owner             = "AWS"
    source_identifier = "VPC_NETWORK_ACL_UNUSED_CHECK"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::NetworkAcl"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "restricted_common_ports" {
  name = "restricted-common-ports"

  source {
    owner             = "AWS"
    source_identifier = "RESTRICTED_INCOMING_TRAFFIC"
  }
  
  input_parameters = jsonencode({
    blockedPort1 = "20"
    blockedPort2 = "21"
    blockedPort3 = "3389"
    blockedPort4 = "3306"
    blockedPort5 = "5432"
  })

  scope {
    compliance_resource_types = ["AWS::EC2::SecurityGroup"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}
