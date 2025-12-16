#!/bin/bash

# WSL Quick Start Script - Enhanced with Full Automation
# Run this for complete CI/CD setup

clear

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     AppleBite CI/CD - WSL 3-VM Quick Start               ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

show_menu() {
    echo "What would you like to do?"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  SETUP OPTIONS"
    echo "═══════════════════════════════════════════════════════════"
    echo "1.  🚀 FULL AUTO SETUP (recommended)"
    echo "    - Creates ProdServer WSL VM"
    echo "    - Configures SSH between VMs"
    echo "    - Installs Jenkins & Ansible on Master"
    echo "    - Updates all configuration files"
    echo "    (TestServer provisioned by Jenkins pipeline)"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  MANUAL STEP-BY-STEP OPTIONS"
    echo "═══════════════════════════════════════════════════════════"
    echo "2.  Create ProdServer WSL instance"
    echo "3.  Setup SSH connectivity between VMs"
    echo "4.  Install Jenkins & Ansible on Master VM"
    echo "5.  Update configuration files with current IPs"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  JENKINS OPTIONS"
    echo "═══════════════════════════════════════════════════════════"
    echo "6.  🔧 Create Jenkins Pipeline (auto-polls GitHub every 5 min)"
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "  UTILITY OPTIONS"
    echo "═══════════════════════════════════════════════════════════"
    echo "7.  Check WSL IP addresses"
    echo "8.  Start all WSL services"
    echo "9.  Test SSH connectivity"
    echo "10. View WSL setup guide"
    echo "11. 🔄 RESET ALL (remove all WSL VMs and configs)"
    echo "12. Exit"
    echo ""
}

full_auto_setup() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║     FULL AUTOMATED SETUP                                 ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    echo "This will:"
    echo "  1. Create ProdServer WSL instance"
    echo "  2. Setup user accounts (nitish/nitish)"
    echo "  3. Configure SSH between Master and Prod VMs"
    echo "  4. Install Jenkins & Ansible on Master VM"
    echo "  5. Update all configuration files"
    echo ""
    echo "Note: TestServer will be provisioned automatically by"
    echo "      Jenkins pipeline when triggered (ephemeral container)."
    echo ""
    echo "This may take 10-15 minutes..."
    echo ""

    # Auto-confirm for fully automated setup
    if [ -z "$AUTO_CONFIRM" ]; then
        echo -n "Continue? (y/n): "
        read confirm

        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            echo "Setup cancelled."
            return
        fi
    else
        echo "AUTO_CONFIRM=yes - proceeding automatically..."
    fi

    script_dir="$(dirname "$0")"

    # Step 1: Create WSL instances
    echo ""
    echo "▶ Step 1/5: Creating WSL instances..."
    if [ -f "$script_dir/auto-create-wsl.sh" ]; then
        bash "$script_dir/auto-create-wsl.sh"
    else
        echo "Error: auto-create-wsl.sh not found"
        return
    fi

    # Step 2: Setup users
    echo ""
    echo "▶ Step 2/5: Setting up user accounts..."
    if [ -f "$script_dir/auto-setup-users.sh" ]; then
        bash "$script_dir/auto-setup-users.sh"
    else
        echo "Error: auto-setup-users.sh not found"
        return
    fi

    # Step 2.5: Restart WSL to apply user changes and get unique IPs
    echo ""
    echo "▶ Restarting WSL VMs to get unique IP addresses..."
    wsl.exe --shutdown
    sleep 3
    echo "✓ WSL restarted - VMs will get unique IPs on next start"

    # Step 3: Setup SSH
    echo ""
    echo "▶ Step 3/5: Setting up SSH connectivity..."
    if [ -f "$script_dir/auto-setup-ssh.sh" ]; then
        bash "$script_dir/auto-setup-ssh.sh"
    else
        echo "Error: auto-setup-ssh.sh not found"
        return
    fi

    # Step 4: Install Jenkins & Ansible
    echo ""
    echo "▶ Step 4/5: Installing Jenkins & Ansible..."
    if [ -f "$script_dir/auto-setup-jenkins-ansible.sh" ]; then
        bash "$script_dir/auto-setup-jenkins-ansible.sh"
    else
        echo "Error: auto-setup-jenkins-ansible.sh not found"
        return
    fi

    # Step 5: Update configs
    echo ""
    echo "▶ Step 5/5: Updating configuration files..."
    if [ -f "$script_dir/auto-update-config.sh" ]; then
        bash "$script_dir/auto-update-config.sh"
    else
        echo "Error: auto-update-config.sh not found"
        return
    fi

    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║     ✓ FULL SETUP COMPLETE!                              ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""

    # Get Master VM
    MASTER_VM=""
    wsl_list=$(wsl.exe --list | tr -d '\r' | tr -d '\0')
    if echo "$wsl_list" | grep -qi "Ubuntu-22.04"; then
        MASTER_VM="Ubuntu-22.04"
    elif echo "$wsl_list" | grep -qi "^Ubuntu$"; then
        MASTER_VM="Ubuntu"
    fi

    master_ip=$(wsl.exe -d "$MASTER_VM" hostname -I 2>/dev/null | tr -d '\r\n ' | awk '{print $1}')

    echo "Your CI/CD environment is ready!"
    echo ""
    echo "Jenkins URL: http://$master_ip:8080"
    echo ""
    echo "Get Jenkins admin password:"
    echo "  wsl -d $MASTER_VM sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
    echo ""
}

create_wsl_instances() {
    echo ""
    echo "Creating ProdServer WSL instance..."
    script_path="$(dirname "$0")/auto-create-wsl.sh"
    if [ -f "$script_path" ]; then
        bash "$script_path"
    else
        echo "Error: auto-create-wsl.sh not found"
    fi
}

setup_ssh() {
    echo ""
    echo "Setting up SSH connectivity..."
    script_path="$(dirname "$0")/auto-setup-ssh.sh"
    if [ -f "$script_path" ]; then
        bash "$script_path"
    else
        echo "Error: auto-setup-ssh.sh not found"
    fi
}

install_jenkins_ansible() {
    echo ""
    echo "Installing Jenkins & Ansible..."
    script_path="$(dirname "$0")/auto-setup-jenkins-ansible.sh"
    if [ -f "$script_path" ]; then
        bash "$script_path"
    else
        echo "Error: auto-setup-jenkins-ansible.sh not found"
    fi
}

update_config() {
    echo ""
    echo "Updating configuration files..."
    script_path="$(dirname "$0")/auto-update-config.sh"
    if [ -f "$script_path" ]; then
        bash "$script_path"
    else
        echo "Error: auto-update-config.sh not found"
    fi
}

reset_all() {
    echo ""
    echo "Resetting all automation..."
    script_path="$(dirname "$0")/auto-reset-all.sh"
    if [ -f "$script_path" ]; then
        bash "$script_path"
    else
        echo "Error: auto-reset-all.sh not found"
    fi
}

check_ips() {
    echo ""
    echo "Checking WSL IP addresses..."
    script_path="$(dirname "$0")/check-wsl-ips.sh"
    if [ -f "$script_path" ]; then
        bash "$script_path"
    else
        echo ""
        echo "Manual IP check:"

        # Detect Master VM
        MASTER_VM=""
        wsl_list=$(wsl.exe --list | tr -d '\r' | tr -d '\0')
        if echo "$wsl_list" | grep -qi "Ubuntu-22.04"; then
            MASTER_VM="Ubuntu-22.04"
        elif echo "$wsl_list" | grep -qi "^Ubuntu$"; then
            MASTER_VM="Ubuntu"
        fi

        echo -n "Master VM ($MASTER_VM):  "; wsl.exe -d "$MASTER_VM" hostname -I 2>/dev/null | tr -d '\r\n '
        echo ""
        echo -n "Test Server:             "; wsl.exe -d TestServer hostname -I 2>/dev/null | tr -d '\r\n '
        echo ""
        echo -n "Prod Server:             "; wsl.exe -d ProdServer hostname -I 2>/dev/null | tr -d '\r\n '
        echo ""
    fi
}

start_services() {
    echo ""
    echo "Starting WSL services..."
    script_path="$(dirname "$0")/start-wsl-services.sh"
    if [ -f "$script_path" ]; then
        bash "$script_path"
    else
        echo "Error: start-wsl-services.sh not found"
    fi
}

test_ssh() {
    echo ""
    echo "Testing SSH connectivity..."

    # Get IPs automatically
    test_ip=$(wsl.exe -d TestServer hostname -I 2>/dev/null | tr -d '\r\n ' | awk '{print $1}')
    prod_ip=$(wsl.exe -d ProdServer hostname -I 2>/dev/null | tr -d '\r\n ' | awk '{print $1}')
    username=$(wsl.exe -d TestServer whoami | tr -d '\r\n ')

    # Detect Master VM
    MASTER_VM=""
    wsl_list=$(wsl.exe --list | tr -d '\r' | tr -d '\0')
    if echo "$wsl_list" | grep -qi "Ubuntu-22.04"; then
        MASTER_VM="Ubuntu-22.04"
    elif echo "$wsl_list" | grep -qi "^Ubuntu$"; then
        MASTER_VM="Ubuntu"
    fi

    if [ -z "$test_ip" ] || [ -z "$prod_ip" ]; then
        echo "Error: Could not get IPs. Make sure VMs are running."
        return
    fi

    echo "Test Server: $test_ip"
    echo "Prod Server: $prod_ip"
    echo "Username: $username"
    echo ""

    echo "Testing connection to Test Server..."
    wsl.exe -d "$MASTER_VM" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$username@$test_ip" "echo 'Test Server: Connected successfully'" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ TestServer connection successful"
    else
        echo "✗ TestServer connection failed"
    fi

    echo ""
    echo "Testing connection to Prod Server..."
    wsl.exe -d "$MASTER_VM" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$username@$prod_ip" "echo 'Prod Server: Connected successfully'" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ ProdServer connection successful"
    else
        echo "✗ ProdServer connection failed"
    fi
}

show_guide() {
    guide_path="$(dirname "$0")/../WSL_SETUP_GUIDE.md"
    if [ -f "$guide_path" ]; then
        echo ""
        echo "Opening WSL Setup Guide..."
        if command -v notepad.exe &>/dev/null; then
            notepad.exe "$guide_path" &
        elif command -v code &>/dev/null; then
            code "$guide_path"
        else
            echo "Please open: $guide_path"
        fi
    else
        echo "Error: WSL_SETUP_GUIDE.md not found"
    fi
}

create_jenkins_pipeline() {
    echo ""
    echo "Creating Jenkins Pipeline..."
    script_path="$(dirname "$0")/auto-create-jenkins-pipeline.sh"
    if [ -f "$script_path" ]; then
        bash "$script_path"
    else
        echo "Error: auto-create-jenkins-pipeline.sh not found"
    fi
}

# Main loop
while true; do
    show_menu
    echo -n "Enter your choice (1-12): "
    read choice

    case $choice in
        1) full_auto_setup ;;
        2) create_wsl_instances ;;
        3) setup_ssh ;;
        4) install_jenkins_ansible ;;
        5) update_config ;;
        6) create_jenkins_pipeline ;;
        7) check_ips ;;
        8) start_services ;;
        9) test_ssh ;;
        10) show_guide ;;
        11) reset_all ;;
        12)
            echo ""
            echo "Goodbye!"
            echo ""
            exit 0
            ;;
        *)
            echo ""
            echo "Invalid choice. Please try again."
            echo ""
            ;;
    esac

    echo ""
    echo "Press Enter to continue..."
    read
    clear
done
