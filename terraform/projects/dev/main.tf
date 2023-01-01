#------------------------------------------------------------------------------
# Terraform project for the dev environment
#------------------------------------------------------------------------------

locals {
  namespace = "ik"
  env       = "dev"
  is_prod   = false
}

terraform {
  required_version = ">= 0.14"

  backend "s3" {
    profile = "terraform-dev"
    region  = "us-east-1"
    bucket  = "924586450630-terraform-state"
    key     = "fargate-standalone-task/terraform.tfstate"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform-dev"
}

module "main" {
  source = "../../modules/main"

  namespace = local.namespace
  env       = local.env
  is_prod   = local.is_prod

  git_branch_name = "cicd" # TODO change to "main

  tags = {}
}
