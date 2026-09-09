@echo off
setlocal EnableExtensions EnableDelayedExpansion
pushd "%~dp0"

set "TARGET_PLATFORM=%~1"
set "PLATFORM_TOOLSET=%~2"
if /i "%TARGET_PLATFORM%"=="x64" (
  set "TARGET_ARCH=x64"
  set "DIST_ARCH=x64"
) else if /i "%TARGET_PLATFORM%"=="Win32" (
  set "TARGET_ARCH=x86"
  set "DIST_ARCH=x86"
) else (
  echo ERRO: arquitetura invalida: %TARGET_PLATFORM%
  goto :fail
)

echo ============================================================
echo VSFilterMod r5.3.1 Vmoe - compilacao Release %DIST_ARCH%
echo ============================================================
echo.

set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (
  echo ERRO: Visual Studio Installer nao encontrado.
  echo Instale o Visual Studio com Desenvolvimento para Desktop com C++.
  goto :fail
)

for /f "usebackq tokens=*" %%I in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VS_PATH=%%I"
if not defined VS_PATH (
  echo ERRO: compilador C++ do Visual Studio nao encontrado.
  goto :fail
)

set "VSDEVCMD=%VS_PATH%\Common7\Tools\VsDevCmd.bat"
if not exist "%VSDEVCMD%" (
  echo ERRO: VsDevCmd.bat nao encontrado em:
  echo   %VSDEVCMD%
  goto :fail
)

call "%VSDEVCMD%" -no_logo -host_arch=x64 -arch=%TARGET_ARCH%
if errorlevel 1 goto :fail

where msbuild >nul 2>nul || (
  echo ERRO: MSBuild nao encontrado apos configurar o Visual Studio.
  goto :fail
)

if not defined VCToolsInstallDir (
  echo ERRO: VCToolsInstallDir nao foi configurado.
  goto :fail
)

if not defined PLATFORM_TOOLSET set "PLATFORM_TOOLSET=%VSFILTERMOD_TOOLSET%"
if not defined PLATFORM_TOOLSET (
  for /f "tokens=1,2 delims=." %%A in ("%VCToolsVersion%") do set "VCTOOLS_MINOR=%%B"
  if not defined VCTOOLS_MINOR (
    echo ERRO: nao foi possivel detectar a versao das ferramentas C++.
    echo Informe o toolset explicitamente, por exemplo: build_x64.bat v143
    goto :fail
  )
  if !VCTOOLS_MINOR! GEQ 50 (
    set "PLATFORM_TOOLSET=v145"
  ) else if !VCTOOLS_MINOR! GEQ 30 (
    set "PLATFORM_TOOLSET=v143"
  ) else if !VCTOOLS_MINOR! GEQ 20 (
    set "PLATFORM_TOOLSET=v142"
  ) else (
    echo ERRO: ferramentas MSVC nao reconhecidas: %VCToolsVersion%
    echo Informe VSFILTERMOD_TOOLSET ou passe o toolset ao script.
    goto :fail
  )
)

if not exist "%VCToolsInstallDir%atlmfc\include\afx.h" (
  echo ERRO: bibliotecas MFC nao encontradas.
  echo Abra o Visual Studio Installer e instale:
  echo   C++ MFC para as ferramentas de build x64/x86 mais recentes
  goto :fail
)

echo Visual Studio: %VS_PATH%
echo Plataforma:    %TARGET_PLATFORM%
echo Toolset:       %PLATFORM_TOOLSET%
echo.

msbuild "VSFilterMod.sln" /m /t:Rebuild /p:Configuration="Release (MOD)" /p:Platform=%TARGET_PLATFORM% /p:PlatformToolset=%PLATFORM_TOOLSET% /p:WindowsTargetPlatformVersion=10.0 /v:minimal
if errorlevel 1 goto :fail

set "BUILT_DLL=bin\%TARGET_PLATFORM%\VSFilter\Release (MOD)\VSFilterMod.dll"
if not exist "%BUILT_DLL%" (
  echo ERRO: a compilacao terminou sem gerar VSFilterMod.dll.
  goto :fail
)

if not exist "dist\%DIST_ARCH%" mkdir "dist\%DIST_ARCH%"
copy /y "%BUILT_DLL%" "dist\%DIST_ARCH%\VSFilterMod.dll" >nul
copy /y "README_PT-BR.md" "dist\README_PT-BR.md" >nul

echo.
echo ============================================================
echo COMPILACAO CONCLUIDA
echo ============================================================
echo DLL:
echo   %CD%\dist\%DIST_ARCH%\VSFilterMod.dll
echo.
popd
exit /b 0

:fail
echo.
echo FALHA NA COMPILACAO. Veja as mensagens acima.
popd
exit /b 1
