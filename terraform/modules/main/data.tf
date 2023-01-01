#------------------------------------------------------------------------------
# External data sources
#------------------------------------------------------------------------------

locals {
  core_prefix = "/ik/dev/core"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "${local.core_prefix}/vpc_id"
}

data "aws_ssm_parameter" "code_pipeline_s3_bucket_arn" {
  name = "${local.core_prefix}/code_pipeline_s3_bucket_arn"
}

data "aws_ssm_parameter" "code_pipeline_s3_bucket_name" {
  name = "${local.core_prefix}/code_pipeline_s3_bucket_name"
}

data "aws_ssm_parameter" "codestar_connection_arn" {
  name = "${local.core_prefix}/codestar_connection_arn"
}

data "aws_ssm_parameter" "data_lake_s3_bucket_name" {
  name = "${local.core_prefix}/data_lake_s3_bucket_name"
}
