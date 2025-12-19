#!/bin/bash

################################################################################
# Setup Local Azure Pipeline Agent
# This script automatically configures a self-hosted agent
################################################################################

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load credentials
source "$PROJECT_ROOT/config/credentials.sh"

echo -e "${BLUE}Setting up local pipeline agent...${NC}"
echo ""

# Agent configuration
AGENT_DIR="$HOME/azpagent"
AGENT_URL="https://download.agent.dev.azure.com/agent/4.264.2/vsts-agent-win-x64-4.264.2.zip"
AGENT_NAME="LocalAgent"
AGENT_POOL="Default"

# Create agent directory
mkdir -p "$AGENT_DIR"

# Check if agent already exists and is configured
if [ -f "$AGENT_DIR/.agent" ]; then
    echo -e "${YELLOW}Agent already configured${NC}"
    echo ""
    echo "Agent details:"
    cat "$AGENT_DIR/.agent" | grep -E "agentName|poolId" || true
    echo ""

    # Check if agent is running
    if pgrep -f "Agent.Listener" > /dev/null; then
        echo -e "${GREEN}✓ Agent is currently running${NC}"
    else
        echo -e "${YELLOW}⚠ Agent is configured but not running${NC}"
        echo ""
        echo "To start the agent, run:"
        echo "  cd $AGENT_DIR"
        if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
            echo "  ./run.cmd"
        else
            echo "  ./run.sh"
        fi
    fi
    echo ""
    exit 0
fi

echo -e "${BLUE}► Downloading agent...${NC}"
cd "$AGENT_DIR"

# Download agent
if [ ! -f "agent.zip" ]; then
    if command -v curl &> /dev/null; then
        curl -L -o agent.zip "$AGENT_URL"
    elif command -v wget &> /dev/null; then
        wget -O agent.zip "$AGENT_URL"
    else
        echo -e "${RED}✗ Neither curl nor wget found${NC}"
        echo "Please download manually from: $AGENT_URL"
        echo "Save to: $AGENT_DIR/agent.zip"
        exit 1
    fi
    echo -e "${GREEN}✓ Agent downloaded${NC}"
else
    echo -e "${GREEN}✓ Agent already downloaded${NC}"
fi

# Extract agent
echo -e "${BLUE}► Extracting agent...${NC}"
if command -v unzip &> /dev/null; then
    unzip -o -q agent.zip
elif command -v powershell.exe &> /dev/null; then
    powershell.exe -Command "Expand-Archive -Path 'agent.zip' -DestinationPath '.' -Force"
else
    echo -e "${RED}✗ No extraction tool found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Agent extracted${NC}"

# Configure agent automatically
echo -e "${BLUE}► Configuring agent...${NC}"
echo ""

# Create unattended config
SERVER_URL="https://dev.azure.com/$AZURE_DEVOPS_ORG"

# Determine the config script
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    CONFIG_SCRIPT="./config.cmd"
    RUN_SCRIPT="./run.cmd"
else
    CONFIG_SCRIPT="./config.sh"
    RUN_SCRIPT="./run.sh"
    chmod +x config.sh
    chmod +x run.sh
fi

# Run configuration in unattended mode
echo "Configuring agent with:"
echo "  Server: $SERVER_URL"
echo "  Pool: $AGENT_POOL"
echo "  Agent: $AGENT_NAME"
echo ""

if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows configuration
    cmd.exe //c "$CONFIG_SCRIPT --unattended --url $SERVER_URL --auth pat --token $AZURE_DEVOPS_PAT --pool $AGENT_POOL --agent $AGENT_NAME --runAsService --replace --acceptTeeEula"
else
    # Linux/Mac configuration
    $CONFIG_SCRIPT --unattended \
        --url "$SERVER_URL" \
        --auth pat \
        --token "$AZURE_DEVOPS_PAT" \
        --pool "$AGENT_POOL" \
        --agent "$AGENT_NAME" \
        --replace \
        --acceptTeeEula
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Agent configured successfully${NC}"
else
    echo -e "${RED}✗ Agent configuration failed${NC}"
    echo ""
    echo "Manual configuration required:"
    echo "1. cd $AGENT_DIR"
    echo "2. Run: $CONFIG_SCRIPT"
    echo "3. Enter:"
    echo "   Server URL: $SERVER_URL"
    echo "   PAT Token: $AZURE_DEVOPS_PAT"
    echo "   Agent pool: $AGENT_POOL"
    echo "   Agent name: $AGENT_NAME"
    exit 1
fi

# Start agent in background
echo ""
echo -e "${BLUE}► Starting agent...${NC}"

if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows - start in new window
    cmd.exe //c "start \"Azure Pipeline Agent\" $RUN_SCRIPT"
    echo -e "${GREEN}✓ Agent started in new window${NC}"
else
    # Linux/Mac - start as service or background process
    if [ -f "./svc.sh" ]; then
        sudo ./svc.sh install
        sudo ./svc.sh start
        echo -e "${GREEN}✓ Agent started as service${NC}"
    else
        nohup $RUN_SCRIPT > agent.log 2>&1 &
        echo -e "${GREEN}✓ Agent started in background${NC}"
    fi
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Local agent setup complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Agent Name: $AGENT_NAME"
echo "Agent Pool: $AGENT_POOL"
echo "Status: Online"
echo ""
echo "View agent status:"
echo "  https://dev.azure.com/$AZURE_DEVOPS_ORG/$AZURE_DEVOPS_PROJECT/_settings/agentqueues"
echo ""
echo "To stop the agent:"
echo "  cd $AGENT_DIR"
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "  Close the agent window or run: taskkill /F /IM Agent.Listener.exe"
else
    echo "  ./svc.sh stop (if running as service)"
    echo "  or: pkill -f Agent.Listener"
fi
echo ""
