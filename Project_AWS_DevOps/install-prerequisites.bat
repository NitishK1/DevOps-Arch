@echo off
REM Quick installer for Terraform and AWS CLI on Windows

echo ============================================
echo  Installing AWS DevOps Prerequisites
echo ============================================
echo.

REM Check if running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Please run this script as Administrator
    pause
    exit /b 1
)

echo Installing AWS CLI v2...
powershell -Command "& {Start-Process msiexec.exe -ArgumentList '/i https://awscli.amazonaws.com/AWSCLIV2.msi /quiet' -Wait}"

echo.
echo Installing Terraform...
powershell -Command "& {Invoke-WebRequest -Uri 'https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_windows_amd64.zip' -OutFile 'terraform.zip'; Expand-Archive -Path 'terraform.zip' -DestinationPath 'C:\terraform' -Force; Remove-Item 'terraform.zip'}"

echo Adding Terraform to PATH...
setx /M PATH "%PATH%;C:\terraform"

echo.
echo ============================================
echo  Installation Complete!
echo ============================================
echo.
echo Please close and reopen your terminal for changes to take effect.
echo Then run: bash scripts/deploy.sh
pause
