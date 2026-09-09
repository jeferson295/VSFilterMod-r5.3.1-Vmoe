@echo off
call "%~dp0build_common.bat" x64 "%~1"
exit /b %errorlevel%
