#Install chocolatey
If ((Get-ExecutionPolicy) -ne 'RemoteSigned') {Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force}
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

#Install general apps
choco install 7zip -y
choco install adobereader -y
choco install ffmpeg -y
choco install Firefox -y #
choco install GoogleChrome -y
choco install paint.net -y #DotNet based paint program thats free
choco install pwsh -y #PowerShell (not Windows PowerShell :D)
choco install lightshot -y #Better screengrabs
choco install screentogif -y #Animated gif maker
choco install remote-desktop-client -y

#Install azure apps
choco install azcopy10 -y
choco install azure-cli -y
choco install azure-iot-installer -y
choco install AzureStorageExplorer -y

#Install cloud native apps
choco install flux -y
choco install kubernetes-cli -y
choco install kubernetes-helm -y

#Install core dev apps (not language specifc)
choco install docker-desktop -y
choco install gh -y
choco install git -y
choco install github-desktop -y
choco install gnupg -y
choco install jq -y
choco install servicebusexplorer -y
choco install vscode -y

#IaC
choco install terraform -y
choco install pulumi -y
