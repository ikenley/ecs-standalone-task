
#------------------------------------------------------------------------------
# A sample ECS Standalone Task meant to be run as an ad-hoc job
#------------------------------------------------------------------------------

locals {
  project_name  = "ecs-standalone-task"
  base_prefix   = [var.namespace, var.env, local.project_name]
  id_prefix     = join("-", local.base_prefix)
  output_prefix = join("/", local.base_prefix)

  tags = merge(var.tags, {
    Terraform   = true
    Environment = var.env
    is_prod     = var.is_prod
  })

  # project-specific
  container_cpu    = 256
  container_memory = 1024
}

