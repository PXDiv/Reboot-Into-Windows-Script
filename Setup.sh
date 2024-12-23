#!/bin/bash

# Function to wait for any key press
wait_for_keypress() {
  echo -e "${CYAN}Press any key to close this window...${RESET}"
  read -n 1 -s
}

# Check if running in a terminal
if [ -z "$TERM" ] || [ ! -t 1 ]; then
  # Detect available terminal emulator
  if command -v gnome-terminal >/dev/null 2>&1; then
    TERMINAL="gnome-terminal"
  elif command -v xterm >/dev/null 2>&1; then
    TERMINAL="xterm"
  elif command -v konsole >/dev/null 2>&1; then
    TERMINAL="konsole --noclose -e"
  elif command -v xfce4-terminal >/dev/null 2>&1; then
    TERMINAL="xfce4-terminal"
  else
    echo "No supported terminal emulator found. Please run this script in a terminal."
    exit 1
  fi

  # Launch a new terminal to run the script
  $TERMINAL -e "bash -c \"$0; exec bash\""
  exit 0
fi

# Define color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Trap errors and display a message
trap 'echo -e "${RED}❌ An error occurred. Setup could not be completed.${RESET}"; exit 1' ERR

# Ensure the script runs with sudo
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}This script requires root permissions. Please enter your password.${RESET}"
  sudo bash "$0" "$@"
  exit
fi

# Detect package manager and update GRUB command
if command -v apt >/dev/null 2>&1; then
  GRUB_UPDATE_CMD="update-grub"
elif command -v dnf >/dev/null 2>&1; then
  GRUB_UPDATE_CMD="grub2-mkconfig -o /boot/grub2/grub.cfg"
elif command -v yum >/dev/null 2>&1; then
  GRUB_UPDATE_CMD="grub2-mkconfig -o /boot/grub2/grub.cfg"
elif command -v pacman >/dev/null 2>&1; then
  GRUB_UPDATE_CMD="grub-mkconfig -o /boot/grub/grub.cfg"
else
  echo -e "${RED}Unsupported package manager or system. Cannot proceed.${RESET}"
  exit 1
fi

# Detect GRUB config location
if [ -f /boot/grub2/grub.cfg ]; then
  GRUB_CONFIG="/boot/grub2/grub.cfg"
elif [ -f /boot/grub/grub.cfg ]; then
  GRUB_CONFIG="/boot/grub/grub.cfg"
else
  echo -e "${RED}GRUB configuration file not found. Ensure GRUB is installed.${RESET}"
  exit 1
fi

# Update GRUB configuration
echo -e "${CYAN}Updating GRUB configuration...${RESET}"
sed -i 's/^GRUB_HIDDEN_TIMEOUT/#GRUB_HIDDEN_TIMEOUT/' /etc/default/grub
sed -i 's/^GRUB_HIDDEN_TIMEOUT_QUIET/#GRUB_HIDDEN_TIMEOUT_QUIET/' /etc/default/grub
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=3/' /etc/default/grub
sed -i 's/^GRUB_TIMEOUT_STYLE=hidden/#GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub

$GRUB_UPDATE_CMD

# Identify Windows GRUB entry
echo -e "${CYAN}Identifying Windows boot entry...${RESET}"
WINDOWS_ENTRY=$(grep -i "windows" "$GRUB_CONFIG" | grep "menuentry '" | sed "s/.*'\\(.*\\)' .*/\\1/" | head -n 1)

if [ -z "$WINDOWS_ENTRY" ]; then
  echo -e "${RED}Could not find a Windows boot entry in GRUB. Please check your GRUB configuration.${RESET}"
  exit 1
fi

echo -e "${GREEN}Found Windows entry: ${YELLOW}$WINDOWS_ENTRY${RESET}"

# Create the reboot script
echo -e "${CYAN}Creating reboot script...${RESET}"
cat <<EOL > /opt/reboot-into-windows
#!/bin/bash
/usr/sbin/grub-reboot "$WINDOWS_ENTRY"
/sbin/reboot
EOL

chmod 755 /opt/reboot-into-windows
chown root:root /opt/reboot-into-windows

# Configure sudoers
echo -e "${CYAN}Configuring sudo permissions...${RESET}"
USERNAME=$(logname)
echo "$USERNAME ALL=(ALL) NOPASSWD: /opt/reboot-into-windows" > /etc/sudoers.d/00-windows-reboot
chmod 440 /etc/sudoers.d/00-windows-reboot

# Detect desktop environment
DE=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')

# Create desktop launcher
echo -e "${CYAN}Creating desktop launcher...${RESET}"
cat <<EOL > /home/$USERNAME/Desktop/reboot-into-windows.desktop
[Desktop Entry]
Name=Reboot into Windows
Comment=Reboots your computer into Windows
Exec=sudo /opt/reboot-into-windows
Icon=computer
Terminal=false
Type=Application
EOL

if [[ $DE == *gnome* || $DE == *unity* || $DE == *pantheon* || $DE == *mate* ]]; then
  gio set /home/$USERNAME/Desktop/reboot-into-windows.desktop metadata::trusted true || chmod +x /home/$USERNAME/Desktop/reboot-into-windows.desktop
else
  chmod +x /home/$USERNAME/Desktop/reboot-into-windows.desktop
fi

chown $USERNAME:$USERNAME /home/$USERNAME/Desktop/reboot-into-windows.desktop

# Success message
echo ""
echo -e "${GREEN}=========================================================${RESET}"
echo -e "🎉 ${GREEN}Setup Complete!${RESET} 🎉"
echo ""
echo -e "A shortcut to reboot into Windows has been created:"
echo -e "   ${YELLOW}Location:${RESET} ${BLUE}/home/$USERNAME/Desktop/reboot-into-windows.desktop${RESET}"
echo ""
echo -e "   ${WHITE}You can double-click the shortcut on your desktop to reboot.${RESET}"
echo -e "   ${RED}If prompted, confirm you trust the file to execute it.${RESET}"
echo ""
echo -e "   ${CYAN}Tip:${RESET} You can also run the following command to reboot:"
echo -e "   ${YELLOW}sudo /opt/reboot-into-windows${RESET}"
echo ""
echo -e "${GREEN}=========================================================${RESET}"

wait_for_keypress

