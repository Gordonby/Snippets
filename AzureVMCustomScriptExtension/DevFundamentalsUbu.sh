sudo apt update && sudo apt upgrade

#Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

#Install stuff with snap
sudo apt install snapd
sudo snap install powershell --classic
sudo snap install helm --classic
sudo snap install kubectl --classic

#Install Node16
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash - &&\
sudo apt-get install -y nodejs

