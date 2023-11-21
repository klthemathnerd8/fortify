
#firewall

echo "Enabling firewall..."
sudo ufw enable
echo "Enabled firewall."

sleep 0.1
#daily updates

echo "Configuring updates..."
echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
echo 'APT::Periodic::Download-Upgradeable-Packages "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
echo 'APT::Periodic::AutocleanInterval "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
echo 'APT::Periodic::Unattended-Upgrade "1";' | sudo tee -a /etc/apt/apt.conf.d/10periodic
echo "Automatic updates have been configured to run daily."

sleep 0.1
#set password for ALL (just sets to current user password which is almost guaranteed to be a secure one)
echo "Setting up passwords..."
CURRENT_USER_PASSWORD=$(grep $(whoami) /etc/shadow | cut -d':' -f2)
for USER in $(getent passwd | cut -d: -f1); do
    echo "$USER:$CURRENT_USER_PASSWORD" | sudo chpasswd
    echo "Password for user '$USER' has been set to the current user's password."
done
echo "Passwords done."
sleep 0.1
#disable ipv4 forwarding
echo "Disabling IPv4 Forwarding..."
sudo echo 0 > /proc/sys/net/ipv4/ip_forward
echo "Disabled IPv4 Forwarding."
sleep 0.1
#update app
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
sleep 0.1
