#!/bin/bash

# Ensure the script runs with sudo
if [ "$EUID" -ne 0 ]; then
  echo "This script requires root permissions. Please enter your password."
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
  echo "Unsupported package manager or system. Cannot proceed."
  exit 1
fi

# Detect GRUB config location
if [ -f /boot/grub2/grub.cfg ]; then
  GRUB_CONFIG="/boot/grub2/grub.cfg"
elif [ -f /boot/grub/grub.cfg ]; then
  GRUB_CONFIG="/boot/grub/grub.cfg"
else
  echo "GRUB configuration file not found. Ensure GRUB is installed."
  exit 1
fi

# Update GRUB configuration
echo "Updating GRUB configuration..."
sed -i 's/^GRUB_DEFAULT=.*$/# GRUB_DEFAULT=0\nGRUB_DEFAULT=saved/' /etc/default/grub
sed -i 's/^#GRUB_TIMEOUT=.*/GRUB_TIMEOUT=3/' /etc/default/grub
$GRUB_UPDATE_CMD

# Identify Windows GRUB entry
echo "Identifying Windows boot entry..."
WINDOWS_ENTRY=$(grep -i "windows" "$GRUB_CONFIG" | grep "menuentry '" | sed "s/.*'\\(.*\\)' .*/\\1/" | head -n 1)

if [ -z "$WINDOWS_ENTRY" ]; then
  echo "Could not find a Windows boot entry in GRUB. Please check your GRUB configuration."
  exit 1
fi

echo "Found Windows entry: $WINDOWS_ENTRY"

# Create the reboot script
echo "Creating reboot script..."
cat <<EOL > /opt/reboot-into-windows
#!/bin/bash
/usr/sbin/grub-reboot "$WINDOWS_ENTRY"
/sbin/reboot
EOL

chmod 755 /opt/reboot-into-windows
chown root:root /opt/reboot-into-windows

# Configure sudoers
echo "Configuring sudo permissions..."
USERNAME=$(logname)
echo "$USERNAME ALL=(ALL) NOPASSWD: /opt/reboot-into-windows" > /etc/sudoers.d/00-windows-reboot
chmod 440 /etc/sudoers.d/00-windows-reboot

# Detect desktop environment
DE=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')

# Create desktop launcher
echo "Creating desktop launcher..."
if [[ $DE == *gnome* || $DE == *unity* || $DE == *pantheon* || $DE == *mate* ]]; then
  TRUST_COMMAND="gio set"
else
  TRUST_COMMAND="chmod +x"
fi

cat <<EOL > /home/$USERNAME/Desktop/reboot-into-windows.desktop
[Desktop Entry]
Name=Reboot into Windows
Comment=Reboots your computer into Windows
Exec=sudo /opt/reboot-into-windows
Icon=computer
Terminal=false
Type=Application
EOL

$TRUST_COMMAND /home/$USERNAME/Desktop/reboot-into-windows.desktop
chown $USERNAME:$USERNAME /home/$USERNAME/Desktop/reboot-into-windows.desktop

echo "Setup complete! A 'Reboot into Windows' shortcut has been created on your desktop. You can double-click it to use it."

