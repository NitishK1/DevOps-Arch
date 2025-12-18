@echo off
REM Windows Batch Script for ProjectX Quickstart
REM This script helps Windows users run the bash scripts

echo ============================================================
echo   ProjectX - Azure DevOps Quickstart (Windows)
echo ============================================================
echo.

REM Check if Git Bash is available
where bash.exe >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Git Bash not found!
    echo.
    echo Please install Git for Windows from: https://git-scm.com/download/win
    echo.
    echo Alternative: Use Windows Subsystem for Linux (WSL)
    echo or Azure Cloud Shell from https://shell.azure.com
    echo.
    pause
    exit /b 1
)

echo Git Bash found. Running quickstart script...
echo.

REM Run the bash script using Git Bash
bash.exe scripts/quickstart.sh

echo.
echo ============================================================
echo   Setup Complete!
echo ============================================================
echo.
pause
