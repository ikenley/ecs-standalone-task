#------------------------------------------------------------------------------
# Configure ECS Task
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# ECR
#------------------------------------------------------------------------------

resource "aws_ecr_repository" "this" {
  name                 = local.id_prefix
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#------------------------------------------------------------------------------
# ECS Task
#------------------------------------------------------------------------------

module "ecs_container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.56.0"

  container_name  = local.project_name
  container_image = "${aws_ecr_repository.this.repository_url}:0.0.4"
  log_configuration = {
    logDriver = "awslogs",
    options = {
      awslogs-group         = "/ecs/${local.id_prefix}",
      awslogs-region        = "us-east-1",
      awslogs-stream-prefix = "ecs"
    }
  }

  map_environment = {
    "DATA_LAKE_BUCKET_NAME" = data.aws_ssm_parameter.data_lake_s3_bucket_name.value
    "FILENAME_PREFIX"       = "output"
  }
}

resource "aws_ecs_task_definition" "this" {
  family = local.id_prefix

  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = local.container_cpu
  memory                   = local.container_memory
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    module.ecs_container_definition.json_map_object
  ])

  # lifecycle {
  #   ignore_changes = [
  #     # Ignore container_definitions b/c this will be managed by CodePipeline
  #     module.ecs_container_definition,
  #   ]
  # }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "task" {
  name = "/ecs/${local.id_prefix}"

  tags = local.tags
}

resource "aws_security_group" "allow_tls" {
  name        = "${local.id_prefix}-task"
  description = "Security group for ECS Task"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  # ingress {
  #   description      = "TLS from VPC"
  #   from_port        = 443
  #   to_port          = 443
  #   protocol         = "tcp"
  #   cidr_blocks      = [aws_vpc.main.cidr_block]
  #   ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  # }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.tags, {
    Name = local.id_prefix
  })
}
