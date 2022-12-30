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
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.id_prefix}-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${local.id_prefix}-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

# resource "aws_iam_policy" "ecs_task_role_app_policy" {
#   name        = "${var.name}-ecs-task-policy"
#   description = "Additional permissions for ECS task application"

#   policy = templatefile("${path.module}/ecs_task_role_policy.tpl", {
#     name = var.name
#   })
# }

# resource "aws_iam_role_policy_attachment" "ecs_task_role_app_policy_attach" {
#   role       = aws_iam_role.ecs_task_role.name
#   policy_arn = aws_iam_policy.ecs_task_role_app_policy.arn
# }

module "ecs_container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.56.0"

  container_name  = aws_ecr_repository.this.name
  container_image = "${aws_ecr_repository.this.repository_url}:latest"
  log_configuration = {
    logDriver = "awslogs",
    options = {
      awslogs-group         = "/ecs/${local.id_prefix}",
      awslogs-region        = "us-east-1",
      awslogs-stream-prefix = "ecs"
    }
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
