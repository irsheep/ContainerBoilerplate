@echo off

if NOT EXIST .env (
  echo Environment file .env not found.
  exit 1
)

:: Load .env as variables
for /F "usebackq delims=" %%i in (`type .env ^| find /v "#"`) do set %%i

:: Tag the 'current' image with the 'latest' tag on the local registry
docker tag ^
  %DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG% ^
  %DOCKER_IMAGE_NAME%:latest

:: Tag the current image to the remote registry
docker tag ^
  %DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG% ^
  %DOCKER_REMOTE_REGISTRY%/%DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG%

:: Push the 'current' image to the remote registry
docker push ^
  %DOCKER_REMOTE_REGISTRY%/%DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG%

:: Links the 'current' tag to the 'latest' tag in the remote registry
docker tag ^
  %DOCKER_REMOTE_REGISTRY%/%DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG% ^
  %DOCKER_REMOTE_REGISTRY%/%DOCKER_IMAGE_NAME%:latest

:: Update the latest tag on the remote registry
docker push %DOCKER_REMOTE_REGISTRY%/%DOCKER_IMAGE_NAME%:latest
