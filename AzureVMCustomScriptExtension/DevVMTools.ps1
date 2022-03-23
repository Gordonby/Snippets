If ((Get-ExecutionPolicy) -ne 'RemoteSigned') {Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force}
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
choco install azcopy -y
choco install vscode -y
choco install pwsh -y
choco install azure-cli -y
choco install kubernetes-cli -y
choco install git -y
choco install kubernetes-helm -y

new-alias k kubectl

#IE Enhanced Security Configuration
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Stop-Process -Name Explorer
