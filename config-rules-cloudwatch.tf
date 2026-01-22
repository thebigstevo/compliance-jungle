# AWS Config Rules for CloudWatch

resource "aws_config_config_rule" "cloudwatch_alarm_action_check" {
  name = "cloudwatch-alarm-action-check"

  source {
    owner             = "AWS"
    source_identifier = "CLOUDWATCH_ALARM_ACTION_CHECK"
  }
  
  input_parameters = jsonencode({
    alarmActionRequired      = "true"
    insufficientDataActionRequired = "false"
    okActionRequired         = "false"
  })

  scope {
    compliance_resource_types = ["AWS::CloudWatch::Alarm"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "cloudwatch_log_group_encrypted" {
  name = "cloudwatch-log-group-encrypted"

  source {
    owner             = "AWS"
    source_identifier = "CLOUDWATCH_LOG_GROUP_ENCRYPTED"
  }
  scope {
    compliance_resource_types = ["AWS::Logs::LogGroup"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}
