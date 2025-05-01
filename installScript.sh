#!/bin/bash

# System Setup Script
# This script helps configure Linux systems based on their type
# It handles different distributions and installs common packages

# Check if running as root
if [ "$UID" -ne 0 ]; then
    echo "This script must be run as root. Elevating privileges..."
    exec sudo bash "$0" "$@"
fi

# Function to install common packages on RPM-based systems
install_rpm_packages() {
    echo "Installing packages for RPM-based system..."
    dnf install epel-release -y
    dnf update -y
    dnf remove libreoffice* -y
    dnf install htop fastfetch wget git curl bleachbit sudo flatpak zsh -y
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    
    # Cleanup
    dnf repoquery --unsatisfied
    dnf autoremove -y
    rpm --rebuilddb
    dnf distro-sync --allowerasing
}

# Function to install common packages on Debian-based systems
install_deb_packages() {
    echo "Installing packages for Debian-based system..."
    apt update
    apt purge -y libreoffice*
    apt install -y htop wget git curl bleachbit unattended-upgrades sudo ufw flatpak zsh btop
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    apt full-upgrade -y
    
    # Cleanup
    apt -y autoremove && apt -y autoclean
    dpkg-reconfigure --priority=low unattended-upgrades
}

# Function to install common packages on Arch-based systems
install_arch_packages() {
    echo "Installing packages for Arch-based system..."
    pacman -Syu --noconfirm
    pacman -R libreoffice* --noconfirm
    pacman -S htop fastfetch wget git curl bleachbit sudo flatpak zsh btop --noconfirm
}

# Function to configure desktop environment
install_desktop_packages() {
    echo "Installing desktop-specific packages..."
    
    # Install desktop-specific packages
    if [ -d /etc/dnf ]; then
        dnf install guake gnome-software-plugin-flatpak -y
        dnf remove -y firefox-esr
    elif [ -d /etc/apt ]; then
        apt install guake gnome-software-plugin-flatpak -y
        apt remove -y firefox-esr
    fi
    
    # Install common desktop flatpaks
    echo "Installing common desktop applications via Flatpak..."
    flatpak install -y com.google.Chrome       
    flatpak install -y com.microsoft.Edge 
    flatpak install -y com.skype.Client 
    flatpak install -y com.spotify.Client 
    flatpak install -y com.brave.Browser  
    flatpak install -y org.mozilla.firefox 
    flatpak install -y com.discordapp.Discord
    flatpak install -y org.onlyoffice.desktopeditors
    flatpak install -y org.videolan.VLC
}

# Function to create a new user
create_user() {
    echo "Creating user 'nate'..."
    if [ -d /etc/dnf ]; then
        useradd -g wheel -s /usr/bin/zsh -m nate
    elif [ -d /etc/apt ]; then
        useradd -g sudo -s /usr/bin/zsh -m nate
    elif [ -d /etc/pacman.d ]; then
        useradd -G wheel -s /usr/bin/zsh -m nate
    fi
    
    # Set password for the new user
    echo "Please set a password for user 'nate':"
    passwd nate
}

# Function to secure root account
secure_root() {
    echo "Securing root account..."
    passwd -l root
}

# Main menu
PS3="What kind of computer is this?: "
options=("Server" "Virtual Machine" "Desktop/Laptop" "Quit")

select opt in "${options[@]}"
do
    case $opt in
        "Server")
            echo "Setting up Server configuration..."
            
            # Install distribution-specific packages
            if [ -d /etc/dnf ]; then
                install_rpm_packages
            elif [ -d /etc/apt ]; then
                install_deb_packages
            elif [ -d /etc/pacman.d ]; then
                install_arch_packages
            else
                echo "Unsupported distribution. Exiting."
                exit 1
            fi
            
            # Create user
            create_user
            
            # Set swappiness for better server performance
            echo "Optimizing swap settings..."
            sysctl vm.swappiness=2
            echo "vm.swappiness=2" >> /etc/sysctl.conf
            
            echo "Server setup completed!"
            break
            ;;
            
        "Virtual Machine")
            echo "Setting up Virtual Machine configuration..."
            
            # Install distribution-specific packages
            if [ -d /etc/dnf ]; then
                install_rpm_packages
            elif [ -d /etc/apt ]; then
                install_deb_packages
            elif [ -d /etc/pacman.d ]; then
                install_arch_packages
            else
                echo "Unsupported distribution. Exiting."
                exit 1
            fi
            
            # Create user
            create_user
            
            # Secure root account
            secure_root
            
            echo "Virtual Machine setup completed!"
            break
            ;;
            
        "Desktop/Laptop")
            echo "Setting up Desktop/Laptop configuration..."
            
            # Install distribution-specific packages
            if [ -d /etc/dnf ]; then
                install_rpm_packages
            elif [ -d /etc/apt ]; then
                install_deb_packages
            elif [ -d /etc/pacman.d ]; then
                install_arch_packages
            else
                echo "Unsupported distribution. Exiting."
                exit 1
            fi
            
            # Create user
            create_user
            
            # Set swappiness for better desktop performance
            echo "Optimizing swap settings..."
            sysctl vm.swappiness=2
            echo "vm.swappiness=2" >> /etc/sysctl.conf
            
            # Secure root account
            secure_root
            
            # Install desktop-specific packages
            install_desktop_packages
            
            echo "Desktop/Laptop setup completed!"
            break
            ;;
            
        "Quit")
            echo "Exiting..."
            exit 0
            ;;
            
        *)
            echo "Invalid option $REPLY. Please choose a valid option."
            ;;
    esac
done

echo "System setup complete. You may need to restart for some changes to take effect."

