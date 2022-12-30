
#------------------------------------------------------------------------------
# A sample ECS Standalone Task meant to be run as an ad-hoc job
#------------------------------------------------------------------------------

locals {
  base_prefix   = [var.namespace, var.env, "ecs-standalone-task"]
  id_prefix     = join("-", local.base_prefix)
  output_prefix = join("/", local.base_prefix)

  tags = merge(var.tags, {
    Terraform   = true
    Environment = var.env
    is_prod     = var.is_prod
  })
}

