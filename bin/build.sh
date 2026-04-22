#!/usr/bin/env sh

[ $(id -u) -ne 0 ] && echo This script must run as root && exit 1

# Load .env as variables
[ ! -f .env ] && echo Environment file .env not found. && exit 2
for f in `cat .env | grep -vE "^#"`; do export ${f}; done

docker buildx build \
  --tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \
  --file conf/Dockerfile \
  .

[ $? -ne 0 ] && echo "Failed to build the docker image" && exit 2

# Update the latest tag
docker tag \
  ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} \
  ${DOCKER_IMAGE_NAME}:latest
