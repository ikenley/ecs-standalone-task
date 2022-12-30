# ecs-standalone-task

A template for an [AWS ECS Fargate](https://aws.amazon.com/fargate/) [standalone task](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_run_task-v2.html). Similar to a [Kubernetes Job](https://kubernetes.io/docs/concepts/workloads/controllers/job/), an ECS Fargate Standalone Task will launch a Docker container that runs until it successfully exits.

Typically ECS Fargate is used to manage continuously running Docker containers. Sometimes you just want to execute some compute and spin down. Useful for small ETL jobs, database migrations, Jenkins-style pipelines, and any other jobs that can be wrapped in a Docker image.

---

## Getting Started

1. Run Terraform to create AWS resources

```
cd terraform/env/dev
terraform init
terraform apply
```

---

## Common commands

```
# Build and run docker image locally
docker build --tag ecs-standalone-task .
docker run --rm ecs-standalone-task HAL
docker tag ecs-standalone-task:latest ecs-standalone-task:latest

# Publish to AWS ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 924586450630.dkr.ecr.us-east-1.amazonaws.com
docker build --tag ecs-standalone-task .
docker tag ecs-standalone-task:latest 924586450630.dkr.ecr.us-east-1.amazonaws.com/ik-dev-ecs-standalone-task:latest
docker push 924586450630.dkr.ecr.us-east-1.amazonaws.com/ik-dev-ecs-standalone-task:latest

# Run the task
# (This can also be done from the AWS ECS console)
./scripts/run_task.sh
```
