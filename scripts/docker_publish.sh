# Build and push docker image to ECR

TAG=$1

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 924586450630.dkr.ecr.us-east-1.amazonaws.com

docker build --tag ecs-standalone-task .

docker tag ecs-standalone-task 924586450630.dkr.ecr.us-east-1.amazonaws.com/ik-dev-ecs-standalone-task:${TAG}
docker push 924586450630.dkr.ecr.us-east-1.amazonaws.com/ik-dev-ecs-standalone-task:${TAG}
