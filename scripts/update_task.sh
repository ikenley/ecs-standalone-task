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
