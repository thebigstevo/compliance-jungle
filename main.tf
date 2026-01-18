# AWS S3 bucket for Config delivery
resource "aws_s3_bucket" "config_bucket" {
  bucket = "compliance-config-monitoring-bucket-25"
}

resource "aws_s3_bucket_versioning" "config_bucket_versioning" {
  bucket = aws_s3_bucket.config_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "config_role" {
  name = "AWSConfigRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = aws_s3_bucket.config_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.config_bucket.arn
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config_bucket.arn}/*" # Add the wildcard for object-level access
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}


# IAM Role Policy for AWS Config
resource "aws_iam_role_policy" "config_policy" {
  role = aws_iam_role.config_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetBucketAcl",
          "s3:PutObject",
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
          "ec2:DescribeInstances",
          "lambda:GetFunctionConfiguration",    # Added for Lambda DLQ Check
          "sqs:GetQueueAttributes",             # Added for DLQ checks if SQS is used as DLQ
          "sqs:ListQueues",                     # Added for identifying queues
          "elasticfilesystem:DescribeFileSystems", # Added for EFS Access Point Enforce Root Directory
          "apigateway:GET",                       # Added for API Gateway checks
          "ecs:DescribeClusters",                 # Added for ECS checks
          "ecs:DescribeServices",                 # Added for ECS checks
          "ecs:DescribeTaskDefinition",           # Added for ECS checks
          "ec2:DescribeVolumes",                  # Added for EBS checks
          "ec2:DescribeSecurityGroups",           # Added for security group checks
          "cloudwatch:DescribeAlarms",            # Added for CloudWatch alarm checks
          "logs:DescribeLogGroups",               # Added for CloudWatch Logs checks
          "config:Put*",
          "config:Get*",
          "config:Describe*",
          "sns:Publish"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported              = true
    include_global_resource_types = true
  }
}


# Delivery Channel
resource "aws_config_delivery_channel" "config_delivery_channel" {
  name           = "config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket

  depends_on = [
    aws_config_configuration_recorder.config_recorder,
    aws_s3_bucket_policy.config_bucket_policy,
    aws_s3_bucket_versioning.config_bucket_versioning
  ]
}

resource "aws_config_configuration_recorder_status" "config_recorder_status" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config_delivery_channel]
}

# Config Rule for S3 Bucket Encryption
resource "aws_config_config_rule" "s3_bucket_encryption" {
  name = "s3-bucket-encryption"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

# Config Rule for EC2 no EC2-No-Amazon-Key-Pair
resource "aws_config_config_rule" "ec2_no_amazon_key_pair" {
  name = "ec2-no-amazon-key-pair"

  source {
    owner             = "AWS"
    source_identifier = "EC2_NO_AMAZON_KEY_PAIR"
  }

  scope {
    compliance_resource_types = [ "AWS::EC2::Instance" ]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

# NOT USED - No Lambda resources
# # Config Rule for EC2 no lambda DLQ check
# resource "aws_config_config_rule" "lambda-dlq-check" {
#   name = "lambda-dlq-check"
# 
#   source {
#     owner             = "AWS"
#     source_identifier = "LAMBDA_DLQ_CHECK"
#   }
#   scope {
#     compliance_resource_types = [ "AWS::Lambda::Function" ]
#   }
#   depends_on = [aws_config_configuration_recorder.config_recorder]
# }

# NOT USED - No EFS resources
# # Config Rule for efs_access_point_enforce_root_directory
# resource "aws_config_config_rule" "efs-access-point-enforce-root-directory" {
#   name = "efs_access_point_enforce_root_directory"
# 
#   source {
#     owner             = "AWS"
#     source_identifier = "EFS_ACCESS_POINT_ENFORCE_ROOT_DIRECTORY"
#   }
#   scope {
#     compliance_resource_types = [ "AWS::EFS::AccessPoint" ]
#   }
#   depends_on = [aws_config_configuration_recorder.config_recorder]
# }

# NOT USED - No API Gateway resources for OpenEMR
# # API Gateway Config Rules
# 
# # Config Rule for API Gateway logging enabled
# resource "aws_config_config_rule" "api_gateway_execution_logging_enabled" {
#   name = "api-gateway-execution-logging-enabled"
# 
#   source {
#     owner             = "AWS"
#     source_identifier = "API_GW_EXECUTION_LOGGING_ENABLED"
#   }
#   scope {
#     compliance_resource_types = ["AWS::ApiGateway::Stage"]
#   }
#   depends_on = [aws_config_configuration_recorder.config_recorder]
# }
# 
# # Config Rule for API Gateway SSL certificate check
# resource "aws_config_config_rule" "api_gateway_ssl_enabled" {
#   name = "api-gateway-ssl-enabled"
# 
#   source {
#     owner             = "AWS"
#     source_identifier = "API_GW_SSL_ENABLED"
#   }
#   scope {
#     compliance_resource_types = ["AWS::ApiGateway::Stage"]
#   }
#   depends_on = [aws_config_configuration_recorder.config_recorder]
# }
# 
# # Config Rule for API Gateway cache encryption
# resource "aws_config_config_rule" "api_gateway_cache_encrypted" {
#   name = "api-gateway-cache-encrypted"
# 
#   source {
#     owner             = "AWS"
#     source_identifier = "API_GW_CACHE_ENABLED_AND_ENCRYPTED"
#   }
#   scope {
#     compliance_resource_types = ["AWS::ApiGateway::Stage"]
#   }
#   depends_on = [aws_config_configuration_recorder.config_recorder]
# }

# NOT USED - No ECS resources for OpenEMR
# # ECS Config Rules
# 
# # Config Rule for ECS task definition memory hard limit
# resource "aws_config_config_rule" "ecs_task_definition_memory_hard_limit" {
#   name = "ecs-task-definition-memory-hard-limit"
# 
#   source {
#     owner             = "AWS"
#     source_identifier = "ECS_TASK_DEFINITION_MEMORY_HARD_LIMIT"
#   }
#   scope {
#     compliance_resource_types = ["AWS::ECS::TaskDefinition"]
#   }
#   depends_on = [aws_config_configuration_recorder.config_recorder]
# }
# 
# # Config Rule for ECS task definition nonroot user
# resource "aws_config_config_rule" "ecs_task_definition_nonroot_user" {
#   name = "ecs-task-definition-nonroot-user"
# 
#   source {
#     owner             = "AWS"
#     source_identifier = "ECS_TASK_DEFINITION_NONROOT_USER"
#   }
#   scope {
#     compliance_resource_types = ["AWS::ECS::TaskDefinition"]
#   }
#   depends_on = [aws_config_configuration_recorder.config_recorder]
# }
# 
# # Config Rule for ECS task definition log configuration
# resource "aws_config_config_rule" "ecs_task_definition_log_configuration" {
#   name = "ecs-task-definition-log-configuration"
# 
#   source {
#     owner             = "AWS"
#     source_identifier = "ECS_TASK_DEFINITION_LOG_CONFIGURATION"
#   }
#   scope {
#     compliance_resource_types = ["AWS::ECS::TaskDefinition"]
#   }
#   depends_on = [aws_config_configuration_recorder.config_recorder]
# }

# EC2/EMR Infrastructure Rules

# Config Rule for EC2 instance detailed monitoring
resource "aws_config_config_rule" "ec2_instance_detailed_monitoring_enabled" {
  name = "ec2-instance-detailed-monitoring-enabled"

  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_DETAILED_MONITORING_ENABLED"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::Instance"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

# Config Rule for EC2 EBS volume encryption
resource "aws_config_config_rule" "ec2_ebs_encryption_by_default" {
  name = "ec2-ebs-encryption-by-default"

  source {
    owner             = "AWS"
    source_identifier = "EC2_EBS_ENCRYPTION_BY_DEFAULT"
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

# Config Rule for attached EBS volumes encrypted
resource "aws_config_config_rule" "encrypted_volumes" {
  name = "encrypted-volumes"

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::Volume"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

# Config Rule for EC2 instance managed by SSM
resource "aws_config_config_rule" "ec2_instance_managed_by_ssm" {
  name = "ec2-instance-managed-by-systems-manager"

  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_MANAGED_BY_SSM"
  }
  scope {
    compliance_resource_types = ["AWS::EC2::Instance"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

# Config Rule for EC2 security group SSH restricted
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

# S3 Backup Rules

# Config Rule for S3 bucket versioning enabled
resource "aws_config_config_rule" "s3_bucket_versioning_enabled" {
  name = "s3-bucket-versioning-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }
  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

# Config Rule for S3 bucket public read prohibited
resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name = "s3-bucket-public-read-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

# Config Rule for S3 bucket public write prohibited
resource "aws_config_config_rule" "s3_bucket_public_write_prohibited" {
  name = "s3-bucket-public-write-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
  }
  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

# Config Rule for S3 bucket logging enabled
resource "aws_config_config_rule" "s3_bucket_logging_enabled" {
  name = "s3-bucket-logging-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_LOGGING_ENABLED"
  }
  scope {
    compliance_resource_types = ["AWS::S3::Bucket"]
  }
  depends_on = [aws_config_configuration_recorder.config_recorder]
}

# CloudWatch Rules

# Config Rule for CloudWatch alarm action check
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

# Config Rule for CloudWatch Log Group encryption
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