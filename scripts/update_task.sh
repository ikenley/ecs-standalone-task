# Run standalone ECS task
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_run_task-v2.html

TASK_DEFINITION_FAMILY=ik-dev-ecs-standalone-task

OLD_TASK_DEFINITION=$(aws ecs describe-task-definition \
--task-definition ik-dev-ecs-standalone-task | jq '.taskDefinition')

echo "OLD_TASK_DEFINITION=$OLD_TASK_DEFINITION"

# --query 'taskDefinition.revision' \
# --output text

IMAGE_URI="924586450630.dkr.ecr.us-east-1.amazonaws.com/ik-dev-ecs-standalone-task:554e3df"

NEW_TASK_DEFINITION=$(echo $OLD_TASK_DEFINITION | \
    jq -r '.containerDefinitions[0].image='\"${IMAGE_URI}\" | \
    jq 'del(.taskDefinitionArn)' | \
    jq 'del(.revision)' | \
    jq 'del(.status)' | \
    jq 'del(.requiresAttributes)' | \
    jq 'del(.compatibilities)' | \
    jq 'del(.registeredAt)' | \
    jq 'del(.registeredBy)')
echo "NEW_TASK_DEFINITION=$NEW_TASK_DEFINITION"

echo "$NEW_TASK_DEFINITION" > new_task_definition.json

aws ecs register-task-definition --family ik-dev-ecs-standalone-task --cli-input-json "$NEW_TASK_DEFINITION"

# TASK_DEFINITION="ik-dev-ecs-standalone-task:${REVISION}"
# echo "TASK_DEFINITION=$TASK_DEFINITION"

# aws ecs run-task \
#     --cluster main \
#     --task-definition $TASK_DEFINITION \
#     --launch-type FARGATE \
#     --network-configuration="awsvpcConfiguration={subnets=[subnet-0e6d4d3994a55e9bd,subnet-0f2afb4dd0b52058c,subnet-089b954f34fa50a96],securityGroups=[sg-0fefee4644905b541],assignPublicIp=DISABLED}" \
#     --overrides file://scripts/overrides.json

