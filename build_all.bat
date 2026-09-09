@echo off
setlocal EnableExtensions
call "%~dp0build_x64.bat"
if errorlevel 1 exit /b 1
call "%~dp0build_x86.bat"
if errorlevel 1 exit /b 1
echo.
echo As duas arquiteturas foram compiladas em dist\.
exit /b 0
