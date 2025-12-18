# Windows Setup Instructions

## Running on Windows

You have several options to run the setup scripts on Windows:

### Option 1: Git Bash (Recommended)

1. **Install Git for Windows** (if not already installed)
   - Download from: https://git-scm.com/download/win
   - During installation, select "Git Bash Here" option

2. **Run the quickstart script**
   ```bash
   # Double-click quickstart.bat
   # Or open Git Bash and run:
   ./scripts/quickstart.sh
   ```

### Option 2: Windows Subsystem for Linux (WSL)

1. **Install WSL** (Windows 10/11)
   ```powershell
   wsl --install
   ```

2. **Open Ubuntu terminal and run**
   ```bash
   cd /mnt/c/Users/your-username/path/to/Project_Azure_DevOps
   ./scripts/quickstart.sh
   ```

### Option 3: Azure Cloud Shell

1. **Open Azure Cloud Shell**
   - Go to: https://shell.azure.com
   - Or click the Cloud Shell icon in Azure Portal

2. **Clone or upload your project**
   ```bash
   # Clone from GitHub (if pushed)
   git clone https://github.com/your-username/your-repo.git
   cd your-repo/Project_Azure_DevOps

   # Or upload files using Cloud Shell upload feature
   ```

3. **Run quickstart**
   ```bash
   ./scripts/quickstart.sh
   ```

### Option 4: PowerShell (Manual Steps)

If you prefer PowerShell, you can run the Azure CLI commands manually:

```powershell
# Login to Azure
az login

# Set subscription
az account set --subscription "Your Subscription ID"

# Create project
az devops project create --name "ProjectX" --org "https://dev.azure.com/YOUR_ORG"

# Continue with other commands from the scripts...
```

See `scripts/` folder for the bash script content to translate.

## Common Windows Issues

### Issue: "bash: command not found"
**Solution:** Install Git Bash or use WSL

### Issue: Line ending problems
**Solution:** Configure Git to use Unix line endings
```bash
git config --global core.autocrlf false
git config --global core.eol lf
```

### Issue: Permission denied when running scripts
**Solution:** In Git Bash:
```bash
chmod +x scripts/*.sh
```

### Issue: Scripts fail with "^M" errors
**Solution:** Convert line endings
```bash
# In Git Bash
dos2unix scripts/*.sh

# Or in PowerShell
(Get-Content scripts/quickstart.sh -Raw) -replace "`r`n","`n" | Set-Content scripts/quickstart.sh -NoNewline
```

## Recommended Approach for Windows Users

For the smoothest experience on Windows:

1. **Use Git Bash** (easiest)
   - Already familiar if you use Git
   - Just double-click `quickstart.bat`

2. **Use Azure Cloud Shell** (if you have issues)
   - Always works
   - No local setup needed
   - Azure CLI pre-installed

3. **Use WSL** (for advanced users)
   - Full Linux environment
   - Better for development

## Testing Your Setup

After choosing your method, test it:

```bash
# Verify Azure CLI
az --version

# Verify bash
bash --version

# Verify git
git --version

# Verify Node.js (for local testing)
node --version
```

All set? Run:
```bash
./scripts/quickstart.sh
```

Or double-click: `quickstart.bat`
