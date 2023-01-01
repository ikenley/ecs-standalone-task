#------------------------------------------------------------------------------
# CI/CD for deployment automation
#------------------------------------------------------------------------------

locals {
  codebuild_project_name = "${local.id_prefix}-docker-build-push"
}

#------------------------------------------------------------------------------
# CodePipeline
#------------------------------------------------------------------------------

resource "aws_codepipeline" "this" {
  name     = local.id_prefix
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = data.aws_ssm_parameter.code_pipeline_s3_bucket_name.value
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        "BranchName" : var.git_branch_name
        "ConnectionArn" : data.aws_ssm_parameter.codestar_connection_arn.value
        "FullRepositoryId" : "ikenley/ecs-standalone-task"
        "OutputArtifactFormat" : "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"

      configuration = {
        ProjectName = local.codebuild_project_name
      }
    }
  }
}

resource "aws_iam_role" "codepipeline" {
  name = "${local.id_prefix}-codepipeline"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "codepipeline" {
  name = "${local.id_prefix}-codepipeline"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${data.aws_ssm_parameter.code_pipeline_s3_bucket_arn.value}",
        "${data.aws_ssm_parameter.code_pipeline_s3_bucket_arn.value}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:UseConnection"
      ],
      "Resource": "${data.aws_ssm_parameter.codestar_connection_arn.value}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codepipeline.arn
}

#------------------------------------------------------------------------------
# CodeBuild
#------------------------------------------------------------------------------

resource "aws_codebuild_project" "docker_build" {
  name        = local.codebuild_project_name
  description = "Docker build and push ${local.id_prefix}"

  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
    name = aws_codepipeline.this.name
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE"]
  }

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "ENV"
      value = var.env
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = local.account_id
    }

    environment_variable {
      name  = "DOCKER_USERNAME"
      type  = "PARAMETER_STORE"
      value = "/docker/username"
    }

    environment_variable {
      name  = "DOCKER_PASSWORD"
      type  = "PARAMETER_STORE"
      value = "/docker/password"
    }

    environment_variable {
      name  = "IMAGE_NAME"
      value = aws_ecr_repository.this.name
    }

    environment_variable {
      name  = "IMAGE_REPO_URL"
      value = aws_ecr_repository.this.repository_url
    }

    environment_variable {
      name  = "TASK_DEFINITION_FAMILY"
      value = aws_ecs_task_definition.this.family
    }
  }

  source {
    type = "CODEPIPELINE"
  }

  tags = local.tags
}

resource "aws_iam_role" "codebuild" {
  name = "${local.id_prefix}-codebuild"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })

  tags = local.tags
}

resource "aws_iam_policy" "codebuild" {
  name = "${local.id_prefix}-codebuild"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowECR",
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:UploadLayerPart",
                "ecr:PutImage",
                "ecr:BatchGetImage",
                "ecr:CompleteLayerUpload",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability"
            ],
            "Resource": [
                "${aws_ecr_repository.this.arn}"
            ]
        },
        {
            "Sid": "AllowECRAuthorizationToken",
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowS3",
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketAcl",
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetBucketLocation",
                "s3:GetObjectVersion"
            ],
            "Resource": [
                "${data.aws_ssm_parameter.code_pipeline_s3_bucket_arn.value}",
                "${data.aws_ssm_parameter.code_pipeline_s3_bucket_arn.value}/*"
            ]
        },
        {
            "Sid": "AllowCodebuildReportGroup",
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutCodeCoverages",
                "codebuild:BatchPutTestCases"
            ],
            "Resource": [
                "arn:aws:codebuild:us-east-1:${local.account_id}:report-group/${local.codebuild_project_name}-*"
            ]
        },
        {
            "Sid": "AllowLogs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "logs:CreateLogStream"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:${local.account_id}:log-group:/aws/codebuild/${local.codebuild_project_name}",
                "arn:aws:logs:us-east-1:${local.account_id}:log-group:/aws/codebuild/${local.codebuild_project_name}:*"
            ]
        },
        {
            "Sid": "AllowSSMDescribeParameters",
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeParameters"
            ],
            "Resource": "*"
        },
        {
          "Sid": "AllowSSMGetParametersDocker",
          "Effect": "Allow",
          "Action": [
              "ssm:GetParameters"
          ],
          "Resource": [
              "arn:aws:ssm:*:*:parameter/docker/*",
              "arn:aws:ssm:*:*:parameter/${local.output_prefix}/codebuild/*"
          ]
        },
        {
          "Sid": "AllowECSUpdate",
          "Effect": "Allow",
          "Action": [
              "ecs:List*",
              "ecs:Describe*",
              "ecs:UpdateService"
          ],
          "Resource": [
            "${aws_ecs_task_definition.this.arn}"
          ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.codebuild.arn
}

