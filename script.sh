#!/bin/bash

# Function to enable firewall
enable_firewall() {
    echo "Enabling firewall..."
    sudo ufw enable
    echo "Enabled firewall."
}

# Function to configure update settings
configure_update_settings() {
    echo "Configuring updates..."
    echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
    echo 'APT::Periodic::Download-Upgradeable-Packages "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
    echo 'APT::Periodic::AutocleanInterval "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
    echo 'APT::Periodic::Unattended-Upgrade "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
    echo "Automatic updates have been configured to run daily."
}

# Function to set passwords for all users
set_passwords() {
    echo "Setting up passwords..."
    CURRENT_USER_PASSWORD=$(grep $(whoami) /etc/shadow | cut -d':' -f2)
    for USER in $(getent passwd | cut -d: -f1); do
        echo "$USER:$CURRENT_USER_PASSWORD" | sudo chpasswd
        echo "Password for user '$USER' has been set to the current user's password."
    done
    echo "Passwords done."
}

# Function to disable IPv4 forwarding
disable_ipv4_forwarding() {
    echo "Disabling IPv4 Forwarding..."
    echo 0 | sudo tee /proc/sys/net/ipv4/ip_forward
    echo "Disabled IPv4 Forwarding."
}

# Function to update applications
update_apps() {
    echo "Updating applications..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get upgrade -y
    elif command -v yum &>/dev/null; then
        sudo yum update -y
    else
        echo "Unsupported package manager. Exiting."
        exit 1
    fi
    echo "Update completed successfully."
}

# Main menu
while true; do
    echo -e "\nFORTIFY\n"
    echo "[1] Enable Firewall"
    echo "[2] Configure Update Settings"
    echo "[3] SetPass"
    echo "[4] Disable IPv4 Forwarding"
    echo "[5] Update Apps"
    echo "[Q] Quit"

    read -p "Choose an option: " option

    case $option in
        1) enable_firewall ;;
        2) configure_update_settings ;;
        3) set_passwords ;;
        4) disable_ipv4_forwarding ;;
        5) update_apps ;;
        q|Q) echo "Exiting."; exit ;;
        *) echo "Invalid option. Please choose again." ;;
    esac
done
