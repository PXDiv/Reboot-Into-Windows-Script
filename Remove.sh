#!/bin/bash

# Function to wait for any key press
wait_for_keypress() {
  echo -e "${CYAN}Press any key to close this window...${RESET}"
  read -n 1 -s
}

# Define color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Trap errors and display a message
trap 'echo -e "${RED}❌ An error occurred. Uninstallation could not be completed.${RESET}"; exit 1' ERR

# Ensure the script runs with sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}This script requires root permissions. Please enter your password.${RESET}"
  sudo bash "$0" "$@"
  exit
fi

# Get the current username (this should match what was used during installation)
USERNAME=$(logname)

# Remove GRUB configuration changes
echo -e "${CYAN}Restoring GRUB configuration...${RESET}"
sed -i 's/^# GRUB_DEFAULT=0\nGRUB_DEFAULT=saved/GRUB_DEFAULT=0/' /etc/default/grub
sed -i 's/GRUB_TIMEOUT=3/#GRUB_TIMEOUT=5/' /etc/default/grub
update-grub

# Remove the reboot script
echo -e "${CYAN}Removing reboot script...${RESET}"
rm -f /opt/reboot-into-windows

# Remove sudoers configuration
echo -e "${CYAN}Removing sudo permissions...${RESET}"
rm -f /etc/sudoers.d/00-windows-reboot

# Remove desktop launcher
echo -e "${CYAN}Removing desktop launcher...${RESET}"
if [ -f "/home/$USERNAME/Desktop/reboot-into-windows.desktop" ]; then
  rm -f "/home/$USERNAME/Desktop/reboot-into-windows.desktop"
else
  echo -e "${YELLOW}Desktop launcher not found. It may have already been removed.${RESET}"
fi

# Success message
echo ""
echo -e "${GREEN}=========================================================${RESET}"
echo -e "🎉 ${GREEN}Uninstallation Complete!${RESET} 🎉"
echo ""
echo -e "All modifications have been reverted and files removed."
echo 	"You can safely delete the desktop shortcut if still present"
echo ""
echo -e "${GREEN}=========================================================${RESET}"
echo ""

wait_for_keypress

