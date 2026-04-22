#!/usr/bin/env sh

[ $(id -u) -ne 0 ] && echo This script must run as root && exit 1

# Load .env as variables
[ ! -f .env ] && echo Environment file .env not found. && exit 2
for f in `cat .env | grep -vE "^#"`; do export ${f}; done

docker run \
  -it \
  -v ./volumes/dir:/some/path \
  -p 8080:80 \
  --name ${CONTAINER_NAME} \
  ${DOCKER_IMAGE_NAME}:latest
