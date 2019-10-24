@echo off

set EXE_FILE_PATH=".\W3xPipeline.exe"
set MAP_FILE_PATH="..\TheLastStand.w3x"
set LOG_FILE_PATH="..\_logs\W3xPipeline.log"

call %EXE_FILE_PATH% %MAP_FILE_PATH% > %LOG_FILE_PATH%
if %ERRORLEVEL% NEQ 0 goto failed

:succeeded
echo Succeeded!
exit

:failed
echo Failed with error code %errorlevel%
echo Check the log file for details %LOG_FILE_PATH%
exit