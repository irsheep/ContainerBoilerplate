@echo off

if NOT EXIST .env (
  echo Environment file .env not found.
  exit 1
)

:: Load .env as variables
for /F "usebackq delims=" %%i in (`type .env ^| find /v "#"`) do set %%i

docker run ^
  -it ^
  -v %cd%\volumes\dir:/some/path ^
  -p 8080:80 ^
  --name %CONTAINER_NAME% ^
  %DOCKER_IMAGE_NAME%:%DOCKER_IMAGE_TAG%
