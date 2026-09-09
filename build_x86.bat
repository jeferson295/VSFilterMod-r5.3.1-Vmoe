@echo off
call "%~dp0build_common.bat" Win32 "%~1"
exit /b %errorlevel%
