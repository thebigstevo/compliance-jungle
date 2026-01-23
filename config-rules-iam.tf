# AWS Config Rules for IAM

resource "aws_config_config_rule" "iam_password_policy" {
  name = "iam-password-policy"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "IAM_PASSWORD_POLICY"
  }
  depends_on = local.config_rule_depends_on
}

resource "aws_config_config_rule" "iam_root_access_key_check" {
  name = "iam-root-access-key-check"

  source {
    owner             = local.aws_rule_owner
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }
  depends_on = local.config_rule_depends_on
}
