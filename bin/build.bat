@echo off

if NOT EXIST .env (
  echo Environment file .env not found.
  exit 1
)

:: Load .env as variables
for /F "usebackq delims=" %%i in (`type .env ^| find /v "#"`) do set %%i

docker build ^
  -t %DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG% ^
  -f conf/Dockerfile .

docker tag ^
  %DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG%  ^
  %DOCKER_IMAGE_NAME%:latest
