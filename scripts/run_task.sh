# Run standalone ECS task
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_run_task-v2.html

aws ecs run-task \
    --cluster main \
    --task-definition ik-dev-ecs-standalone-task:1 \
    --launch-type FARGATE \
    --network-configuration="awsvpcConfiguration={subnets=[subnet-0e6d4d3994a55e9bd,subnet-0f2afb4dd0b52058c,subnet-089b954f34fa50a96],securityGroups=[sg-0fefee4644905b541],assignPublicIp=DISABLED}"

