# Run standalone ECS task
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_run_task-v2.html

OLD_TASK_DEFINITION=$(aws ecs describe-task-definition \
--task-definition ik-dev-ecs-standalone-task)

echo "OLD_TASK_DEFINITION=$OLD_TASK_DEFINITION"

# --query 'taskDefinition.revision' \
# --output text

TASK_DEFINITION="ik-dev-ecs-standalone-task:${REVISION}"
echo "TASK_DEFINITION=$TASK_DEFINITION"

aws ecs run-task \
    --cluster main \
    --task-definition $TASK_DEFINITION \
    --launch-type FARGATE \
    --network-configuration="awsvpcConfiguration={subnets=[subnet-0e6d4d3994a55e9bd,subnet-0f2afb4dd0b52058c,subnet-089b954f34fa50a96],securityGroups=[sg-0fefee4644905b541],assignPublicIp=DISABLED}" \
    --overrides file://scripts/overrides.json

