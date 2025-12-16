#!/bin/bash

# WSL IP Checker Script
# Run this to get all WSL instance IPs

echo ""
echo "=== WSL Instance IP Addresses ==="
echo ""

instances=("Ubuntu" "TestServer" "ProdServer")

for instance in "${instances[@]}"; do
    ip=$(wsl.exe -d "$instance" hostname -I 2>/dev/null | tr -d '\r\n ')
    if [ $? -eq 0 ] && [ ! -z "$ip" ]; then
        printf "%-15s : %s\n" "$instance" "$ip"
    else
        printf "%-15s : Not found or not running\n" "$instance"
    fi
done

echo ""
echo "================================="
echo ""
echo "Copy these IPs to your configuration files:"
echo ""
