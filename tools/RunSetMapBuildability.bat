@echo off
call .\SetMapBuildability.exe "..\TheLastStand.w3x"
if errorlevel -1 goto failed
echo Done...
:failed
echo Failed with error code %errorlevel%