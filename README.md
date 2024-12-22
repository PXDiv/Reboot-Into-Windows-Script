# Reboot Into Windows Script

This script allows Linux users with GRUB as the bootloader to reboot directly into Windows with a single click. It automatically detects your Windows boot entry in GRUB and creates a desktop shortcut to reboot into Windows easily. This script works on most Linux distributions like Ubuntu, Fedora, Arch Linux, and more.

## Features

- **Automatically detects Windows boot entry**: The script identifies the Windows boot option in your GRUB configuration.
- **Creates a Desktop Shortcut**: A `.desktop` file is created for easy execution via GUI. The shortcut works for GNOME, KDE, XFCE, and other major desktop environments.
- **Works on multiple Linux distributions**: Compatible with Debian-based (Ubuntu), Fedora, CentOS, Arch Linux, and others.
- **No extra dependencies**: Does not require any additional software outside the basic Linux environment and GRUB bootloader.

## Desktop Environment Support

- The script automatically detects your desktop environment and adjusts the `.desktop` file accordingly.
- It works on GNOME, KDE, XFCE, MATE, and others. The script marks the `.desktop` file as trusted for GNOME-based environments (using `gio set`) and sets it executable for others (using `chmod +x`).

## Requirements

- **GRUB bootloader**: This script works only if GRUB is used as the bootloader. It’s compatible with most Linux distributions using GRUB.
- **Sudo privileges**: The script requires root (`sudo`) access to modify GRUB and create system files.

## Installation Instructions

1. **Download the Script**
    ![1](https://github.com/user-attachments/assets/1fa90563-2646-49d2-8290-dd611111553d)

    Navigate to the folder where the script is located

2. **Run the Script**

   Go to the properties of the script to allow it to be executed
    ![2](https://github.com/user-attachments/assets/252271d5-67bb-4c56-ac1e-9e0964752b33)

   Turn on "Execute as Program"
   ![4](https://github.com/user-attachments/assets/5f1e4b19-8754-4c4c-aa28-a5c5d070d096)

   Now Right Click and Run as Program
   ![5](https://github.com/user-attachments/assets/19c2a738-2751-4db4-a6e2-30ef47be915b)
   
   The script will ask for your password to make necessary system changes (like updating GRUB and creating files in `/opt`).

4. **After the Installation**
    ![6](https://github.com/user-attachments/assets/18679c49-9da3-4282-930b-67834a343af4)
    The Script will automatically place a shortcut on your desktop
   
    ![7](https://github.com/user-attachments/assets/e7d54f84-05cc-4ff7-8038-c8a93b64b835)
    Allow the Shortcut to be executed and double click the shortcut to now run it.

## How the Script Works

1. **Step 1: Detect Windows GRUB Entry**  
    The script scans your GRUB configuration file (`/boot/grub/grub.cfg` or `/boot/grub2/grub.cfg`) for any Windows boot entries.

2. **Step 2: Create Reboot Script**  
    It creates a script at `/opt/reboot-into-windows` that tells GRUB to boot into Windows and then reboots the system.

3. **Step 3: Create Desktop Shortcut**  
    A `.desktop` file is created on the user's desktop, which can be double-clicked to reboot into Windows.

4. **Step 4: Set Permissions**  
    It sets up the appropriate sudo permissions to allow the script to run without entering the password every time.

## Usage

- After installation, you’ll see a new shortcut on your desktop named **"Reboot into Windows"**.
- To reboot into Windows, simply double-click the shortcut.
- If prompted, enter your password for sudo access (if not set up for passwordless sudo).

## Customizing the Script

You can manually adjust the script if:

- **You use a different bootloader**: The script is designed for GRUB, and if you're using something else (like `systemd-boot` or `rEFInd`), you'll need to modify the script.
- **You want to change the GRUB timeout**: Edit the line setting the GRUB timeout in `/etc/default/grub`.

## Troubleshooting

- **No Windows entry found**: Ensure that your GRUB configuration contains a valid Windows entry. If not, you may need to repair or update your GRUB.
- **Desktop shortcut not working**: If the `.desktop` file doesn’t appear or doesn’t work, try marking it as executable manually:

    ```bash
    chmod +x /home/username/Desktop/reboot-into-windows.desktop
    ```

## Contributing

Feel free to fork the repository, submit issues, and propose changes via pull requests. Your contributions are welcome!

- Report bugs or request features through the **Issues** section on GitHub.
- Provide improvements or fixes by submitting a **pull request**.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- This script leverages GRUB to identify the Windows boot entry. Thanks to the GRUB project for providing such an accessible way to interact with the bootloader.
