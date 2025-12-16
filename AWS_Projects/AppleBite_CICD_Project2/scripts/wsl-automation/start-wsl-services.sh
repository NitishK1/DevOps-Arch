#!/bin/bash

# WSL Services Startup Script
# Run this after Windows reboot to start all services

echo ""
echo "=== Starting WSL Services ==="
echo ""

# Start Master VM services
echo "Starting Master VM (Ubuntu) services..."
wsl.exe -d Ubuntu -u root -- bash -c "service ssh start && service jenkins start" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ Master VM services started"
else
    echo "✗ Failed to start Master VM services"
fi

# Start Test Server SSH
echo ""
echo "Starting Test Server services..."
wsl.exe -d TestServer -u root -- service ssh start 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ Test Server SSH started"
else
    echo "✗ Failed to start Test Server SSH"
fi

# Start Prod Server SSH
echo ""
echo "Starting Production Server services..."
wsl.exe -d ProdServer -u root -- service ssh start 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ Production Server SSH started"
else
    echo "✗ Failed to start Production Server SSH"
fi

echo ""
echo "=== All WSL Services Started ==="
echo ""

# Display IPs
echo "Current IP Addresses:"
master_ip=$(wsl.exe -d Ubuntu hostname -I 2>/dev/null | tr -d '\r\n ')
test_ip=$(wsl.exe -d TestServer hostname -I 2>/dev/null | tr -d '\r\n ')
prod_ip=$(wsl.exe -d ProdServer hostname -I 2>/dev/null | tr -d '\r\n ')

[ ! -z "$master_ip" ] && echo "Master VM:    $master_ip"
[ ! -z "$test_ip" ] && echo "Test Server:  $test_ip"
[ ! -z "$prod_ip" ] && echo "Prod Server:  $prod_ip"

echo ""
echo "Jenkins URL: http://localhost:8080"
echo ""
