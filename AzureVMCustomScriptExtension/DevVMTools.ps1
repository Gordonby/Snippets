If ((Get-ExecutionPolicy) -ne 'RemoteSigned') {Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force}
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
choco install azcopy -y
choco install vscode -y
choco install pwsh -y
choco install azure-cli -y
choco install kubernetes-cli -y
choco install git -y
