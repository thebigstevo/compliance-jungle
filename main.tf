# AWS Config for OpenEMR Compliance Monitoring
# 
# This Terraform configuration sets up AWS Config to monitor compliance
# for an EC2-based OpenEMR healthcare application deployment.
#
# File Structure:
# - config-infrastructure.tf: S3 bucket, IAM role, recorder, delivery channel
# - config-rules-ec2.tf: EC2 and EBS compliance rules
# - config-rules-s3.tf: S3 bucket compliance rules
# - config-rules-network.tf: VPC and security group rules
# - config-rules-cloudwatch.tf: CloudWatch monitoring rules
# - config-rules-iam.tf: IAM security rules
# - variables.tf: Input variables
# - provider.tf: AWS provider configuration
