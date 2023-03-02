Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#Install azure apps
choco install azcopy10 -y
choco install azure-cosmosdb-emulator -y
choco install AzureStorageExplorer -y

#Azure CLI is already installed in base VM Image.
#choco install azure-cli -y

#Install vscode ide
choco install -y vscode
