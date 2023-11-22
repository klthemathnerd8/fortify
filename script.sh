#!/bin/bash

# Function to clear the screen
clear_screen() {
    if command -v tput &>/dev/null; then
        tput clear
    elif command -v clear &>/dev/null; then
        clear
    else
        echo "Screen clearing not supported in this environment."
    fi
}

# Function to enable firewall
enable_firewall() {
    echo "Enabling firewall..."
    sudo ufw enable
    echo "Enabled firewall."
    sleep 3
    clear_screen
}

#Function to manage users
usermanage() {
USERS=($(getent passwd | cut -d: -f1))
CURRENT_USER_INDEX=0

while [ $CURRENT_USER_INDEX -lt ${#USERS[@]} ]; do
    CURRENT_USER=${USERS[$CURRENT_USER_INDEX]}
    ADMIN_STATUS=$(id -u $CURRENT_USER)

    echo "Administrator $CURRENT_USER, $ADMIN_STATUS."
    echo "[1] Grant admin (makes them administrator if not one already)"
    echo "[2] Remove admin (makes them common user if not one already)"
    echo "[3] Remove the user and their files (gives a warning)"
    echo "[4] Move on to the next user (unless this is the last user, upon which it quits.)"

    read -p "Choose an option: " OPTION

    case $OPTION in
        1) # Grant admin
            sudo usermod -aG sudo $CURRENT_USER
            ;;
        2) # Remove admin
            sudo deluser $CURRENT_USER sudo
            ;;
        3) # Remove user and files
            read -p "Are you sure you want to remove user $CURRENT_USER and their files? (y/n): " CONFIRM
            if [ "$CONFIRM" == "y" ]; then
                sudo deluser --remove-home $CURRENT_USER
            else
                echo "Operation canceled."
            fi
            ;;
        4) # Move to next user
            ((CURRENT_USER_INDEX++))
            ;;
        *) # Invalid option
            echo "Invalid option. Please choose again."
            ;;
    esac
done
}

# Function to configure update settings
configure_update_settings() {
    echo "Configuring updates..."
    echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
    echo 'APT::Periodic::Download-Upgradeable-Packages "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
    echo 'APT::Periodic::AutocleanInterval "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
    echo 'APT::Periodic::Unattended-Upgrade "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
    echo "Automatic updates have been configured to run daily."
    sleep 3
    clear_screen
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
    sleep 3
    clear_screen
}

# Function to disable IPv4 forwarding
disable_ipv4_forwarding() {
    echo "Disabling IPv4 Forwarding..."
    echo 0 | sudo tee /proc/sys/net/ipv4/ip_forward
    echo "Disabled IPv4 Forwarding."
    sleep 3
    clear_screen
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
    sleep 3
    clear_screen
}

# Function to set password max age
set_password_max_age() {
    read -p "Enter the maximum password age (in days): " max_age
    sudo chage --maxdays $max_age --allusers
    echo "Maximum password age set to $max_age days for all users."
    sleep 3
    clear_screen
}

# Main menu
while true; do
    echo -e "\nFORTIFY\n"
    echo "[1] Enable Firewall"
    echo "[2] Configure Update Settings"
    echo "[3] SetPass"
    echo "[4] Disable IPv4 Forwarding"
    echo "[5] Update Apps"
    echo "[6] Set Password Max Age"
    echo "[7] Manage Users"
    echo "[Q] Quit"

    read -p "Choose an option: " option

    case $option in
        1) enable_firewall ;;
        2) configure_update_settings ;;
        3) set_passwords ;;
        4) disable_ipv4_forwarding ;;
        5) update_apps ;;
        6) set_password_max_age ;;
        7) usermanage ;;
        q|Q) echo "Exiting."; exit ;;
        *) echo "Invalid option. Please choose again." ;;
    esac
done
