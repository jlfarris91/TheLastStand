@echo off

set MAP_NAME=TheLastStand.w3x

set EXE_FILE_PATH=.\W3xPipeline.exe
set MAP_DIR_PATH=..\maps\%MAP_NAME%
set MAP_OUTPUT_PATH=..\%MAP_NAME%
set INTERMEDIATE_DIR_PATH=..\_build\maps

set LOG_DIR=..\_logs\
set LOG_FILE_PATH=%LOG_DIR%W3xPipeline.log

if not exist "%LOG_DIR%" md "%LOG_DIR%"

call "%EXE_FILE_PATH%" "%MAP_DIR_PATH%" "%MAP_OUTPUT_PATH%" "%INTERMEDIATE_DIR_PATH%" > "%LOG_FILE_PATH%"
if %ERRORLEVEL% NEQ 0 goto failed

:succeeded
echo Succeeded!
exit

:failed
echo Failed with error code %errorlevel%
echo Check the log file for details %LOG_FILE_PATH%
exit