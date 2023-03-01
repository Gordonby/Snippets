Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
iex ((New-Object System.Net.WebClient).DownloadString(\'https://community.chocolatey.org/install.ps1\'))

#Install azure apps
choco install azcopy10 -y
choco install azure-cli -y
choco install azure-iot-installer -y
choco install AzureStorageExplorer -y

#Install vscode ide
choco install -y vscode
