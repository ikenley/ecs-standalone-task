#------------------------------------------------------------------------------
# IAM
#------------------------------------------------------------------------------

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

resource "aws_iam_policy" "ecs_task_role" {
  name        = "${local.id_prefix}-task-role"
  description = "Additional permissions for ECS task application"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListBucket"
        Effect = "Allow"
        Action = [
          "s3:List*"
        ]
        Resource = "arn:aws:s3:::${data.aws_ssm_parameter.data_lake_s3_bucket_name.value}"
      },
      {
        Sid    = "ReadWriteBucket"
        Effect = "Allow"
        Action = [
          "s3:DeleteObject",
          "s3:Get*",
          "s3:Put*"
        ]
        Resource = "arn:aws:s3:::${data.aws_ssm_parameter.data_lake_s3_bucket_name.value}/ecs-standalone-task/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role.arn
}

