#------------------------------------------------------------------------------
# External data sources
#------------------------------------------------------------------------------

locals {
    core_prefix = "/ik/dev/core"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "${local.core_prefix}/vpc_id"
}