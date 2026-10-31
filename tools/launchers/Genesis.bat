@echo off
rem Starts Genesis Community. Keep this file beside Genesis.exe and Genesis.pck.
rem   Genesis.bat                    start Genesis
rem   Genesis.bat "C:\path\project"  start Genesis with a project open
setlocal
set "HERE=%~dp0"
if not exist "%HERE%Genesis.exe" (
  echo Genesis.exe is not beside this file ^(%HERE%^).
  pause
  exit /b 1
)
start "" "%HERE%Genesis.exe" %*
