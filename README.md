# ecs-standalone-task

A template for an [AWS ECS Fargate](https://aws.amazon.com/fargate/) [standalone task](https://docs.aws.amazon.com/AmazonECS/0.0.1/developerguide/ecs_run_task-v2.html). Similar to a [Kubernetes Job](https://kubernetes.io/docs/concepts/workloads/controllers/job/), an ECS Fargate Standalone Task will launch a Docker container that runs until it successfully exits.

Typically ECS Fargate is used to manage continuously running Docker containers. Sometimes you just want to execute some compute and spin down. Useful for small ETL jobs, database migrations, Jenkins-style pipelines, and any other jobs that can be wrapped in a Docker image.

---

## Getting Started

1. Run Terraform to create AWS resources

```
cd terraform/projects/dev
terraform init
terraform apply
```

---

## Common commands

```
# Build and run docker image locally
docker build --tag ecs-standalone-task --build-arg IMAGE_TAG=1234567 .
docker run --rm -e FILENAME_PREFIX="local" -e DATA_LAKE_BUCKET_NAME=924586450630-data-lake ecs-standalone-task


# Publish to AWS ECR
./scripts/docker_publish.sh 0.0.3

# Run the task
# (This can also be done from the AWS ECS console)
./scripts/run_task.sh
```
