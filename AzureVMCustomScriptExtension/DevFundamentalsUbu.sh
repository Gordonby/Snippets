sudo apt update && sudo apt upgrade

sudo apt install curl

#Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

#Install PowerShell
sudo dpkg -i powershell-lts_7.3.6-1.deb_amd64.deb
sudo apt-get install -f

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

