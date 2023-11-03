sudo apt update && sudo apt upgrade

sudo apt install curl

#Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

#Install PowerShell
sudo apt-get install -y wget apt-transport-https software-properties-common
source /etc/os-release
wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell

#Install PowerShell Modules
Install-Module -Name Az -Repository PSGallery -Force

#Install stuff with snap
sudo apt install snapd
sudo snap install powershell --classic
sudo snap install helm --classic
sudo snap install kubectl --classic

#Install other tools
sudo apt install jq

#Install Node16
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash - &&\
sudo apt-get install -y nodejs

