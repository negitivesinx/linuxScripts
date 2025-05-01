#!/bin/bash
#pwsh for debian
curl https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --yes --dearmor --output /usr/share/keyrings/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/microsoft-debian-bullseye-prod bullseye main" > /etc/apt/sources.list.d/microsoft.list'
sudo apt update && sudo apt install -y powershell
#azCLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
#pwsh for RH
sudo dnf install https://github.com/PowerShell/PowerShell/releases/download/v7.3.6/powershell-7.3.6-1.rh.x86_64.rpm
#AZcli
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
sudo dnf install azure-cli
#Install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo dnf install guake  epel-release gnome-software flatpak gnome-software-plugin-flatpak fastfetch
sudo apt install guake gnome-software flatpak gnome-software-plugin-flatpak fastfetch
#remove firefox
sudo dnf remove firefox*
sudo apt remove firefox*
#install MSedge
flatpak install -y com.microsoft.Edge 
#install onlyoffice
flatpak install -y org.onlyoffice.desktopeditorsf
#install VLC
flatpak install -y org.videolan.VLC  
#Teams for linux
flatpak install flathub com.github.IsmaelMartinez.teams_for_linux
#Chromium 
flatpak install com.github.Eloston.UngoogledChromium

