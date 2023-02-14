@echo off

:: Create the default settings.env if it does not exist
if NOT EXIST conf\settings.env (
  echo settings.env not found, using defaults.
  copy conf\settings.default.env conf\settings.env
)

:: Load container setup variables
for /F "usebackq" %%i in (conf\settings.env) do set %%i

:: Define the image source
set IMAGE_SOURCE=%IMAGE_NAME%
if DEFINED PRIVATE_REGISTRY (
  set IMAGE_SOURCE=%PRIVATE_REGISTRY%/%IMAGE_NAME%
)

docker run ^
-d ^
-v %cd%\volumes:/some/path ^
-p 80:80 ^
--name %CONTAINER_NAME% ^
%IMAGE_SOURCE%:%IMAGE_TAG%
