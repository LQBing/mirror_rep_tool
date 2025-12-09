@echo off
setlocal enabledelayedexpansion

:: DOCKER_MIRROR_REP=<yourrep>/<namespace>/<imagename>
:: DOCKER_TRANSPORT_SERVER_HOST=

if "%DOCKER_MIRROR_REP%"=="" (
    echo DOCKER_MIRROR_REP can not be null
    exit /b 1
)

set "IMAGE_FULL=%1"
if "%IMAGE_FULL%"=="" (
    echo Image name is required
    exit /b 1
)

:: parse image name
set "REGISTRY="
set "NAMESPACE="
set "IMAGE_NAME="
set "TAG=latest"

set TEMP_IMAGE=%IMAGE_FULL%

:: count slashes
set "SLASH_COUNT=0"
set "STR=%TEMP_IMAGE%"
:count_slashes
if not "!STR:/=!"=="!STR!" (
    set /a SLASH_COUNT+=1
    set "STR=!STR:/=!"
    goto count_slashes
)

:: parse image name
if !SLASH_COUNT! equ 0 (
    set "NAMESPACE=library"
    set "IMAGE_NAME=%TEMP_IMAGE%"
) else if !SLASH_COUNT! equ 1 (
    for /f "tokens=1,2 delims=/" %%a in ("%TEMP_IMAGE%") do (
        set "NAMESPACE=%%a"
        set "IMAGE_NAME=%%b"
    )
) else if !SLASH_COUNT! equ 2 (
    for /f "tokens=1,2,3 delims=/" %%a in ("%TEMP_IMAGE%") do (
        set "REGISTRY=%%a"
        set "NAMESPACE=%%b"
        set "IMAGE_NAME=%%c"
    )
) else (
    echo wrong image name
    exit /b 1
)

:: parse tag
set "FINAL_IMAGE_NAME=%IMAGE_NAME%"
if not "%IMAGE_NAME: =%"=="%IMAGE_NAME%" (
    echo wrong image name
    exit /b 1
)

set "HAS_TAG=0"
set "TEMP_TAG=%IMAGE_NAME%"
:TAG_CHECK
if not "!TEMP_TAG::=!"=="!TEMP_TAG!" (
    set "HAS_TAG=1"
    goto TAG_SPLIT
)
goto TAG_DONE

:TAG_SPLIT
for /f "tokens=1,2 delims=:" %%a in ("%IMAGE_NAME%") do (
    set "FINAL_IMAGE_NAME=%%a"
    set "TAG=%%b"
)

:TAG_DONE

:: Check tag null
if "%TAG%"=="" (
    set "TAG=latest"
)

:: debug info
:: echo Registry: %REGISTRY%
:: echo Namespace: %NAMESPACE%
:: echo Image: %FINAL_IMAGE_NAME%
:: echo Tag: %TAG%

:: pull image

echo pull %DOCKER_MIRROR_REP%:%NAMESPACE%_%FINAL_IMAGE_NAME%_%TAG%
docker pull %DOCKER_MIRROR_REP%:%NAMESPACE%_%FINAL_IMAGE_NAME%_%TAG%

if errorlevel 1 (
    if not "%DOCKER_TRANSPORT_SERVER_HOST%"=="" (
        echo Pull failed, trying to push from remote server...
        echo ssh -o StrictHostKeyChecking=no %DOCKER_TRANSPORT_SERVER_HOST% "export DOCKER_MIRROR_REP=%DOCKER_MIRROR_REP%; pushimage %1"
        ssh -o StrictHostKeyChecking=no %DOCKER_TRANSPORT_SERVER_HOST% "export DOCKER_MIRROR_REP=%DOCKER_MIRROR_REP%; pushimage %1"
        docker pull %DOCKER_MIRROR_REP%:%NAMESPACE%_%FINAL_IMAGE_NAME%_%TAG%
    )
)

if errorlevel 1 (
    echo Failed to pull image from mirror repository
    exit /b 1
)

echo tag %DOCKER_MIRROR_REP%:%NAMESPACE%_%FINAL_IMAGE_NAME%_%TAG% %1
docker tag %DOCKER_MIRROR_REP%:%NAMESPACE%_%FINAL_IMAGE_NAME%_%TAG% %1

if errorlevel 1 (
    echo Failed to tag image
    exit /b 1
)

:: push image

:: echo pull %1
:: docker pull %1
:: if errorlevel 1 (
::     echo Failed to pull image
::     exit /b 1
:: )

:: echo tag %1 %DOCKER_MIRROR_REP%:%NAMESPACE%_%FINAL_IMAGE_NAME%_%TAG% 
:: docker tag %1 %DOCKER_MIRROR_REP%:%NAMESPACE%_%FINAL_IMAGE_NAME%_%TAG% 
:: if errorlevel 1 (
::     echo Failed to tag image
::     exit /b 1
:: )

:: echo push %DOCKER_MIRROR_REP%:%NAMESPACE%_%FINAL_IMAGE_NAME%_%TAG% 
:: docker push %DOCKER_MIRROR_REP%:%NAMESPACE%_%FINAL_IMAGE_NAME%_%TAG% 
:: if errorlevel 1 (
::     echo Failed to push image
::     exit /b 1
:: )

endlocal
