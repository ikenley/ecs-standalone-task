# Generic BASH script
# The ECS task will spin up, run this script, and then exit
# Local debugging:
# DATA_LAKE_BUCKET_NAME=924586450630-data-lake ./src/main.sh

echo "Open the pod bay doors, HAL"

echo "IMAGE_TAG=$IMAGE_TAG"

echo "DATA_LAKE_BUCKET_NAME=$DATA_LAKE_BUCKET_NAME"
OUTPUT_DIRECTORY="ecs-standalone-task/output"
TIMESTAMP=$(date +%s)
S3_KEY_PREFIX="${OUTPUT_DIRECTORY}/${FILENAME_PREFIX}-${TIMESTAMP}.txt"

echo "S3_KEY_PREFIX=$S3_KEY_PREFIX"

mkdir -p /tmp/${OUTPUT_DIRECTORY}
echo "Open the pod bay doors, HAL" > /tmp/${S3_KEY_PREFIX}

aws s3 cp /tmp/${S3_KEY_PREFIX} s3://${DATA_LAKE_BUCKET_NAME}/${S3_KEY_PREFIX}