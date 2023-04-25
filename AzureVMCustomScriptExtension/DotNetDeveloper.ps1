If ((Get-ExecutionPolicy) -ne 'RemoteSigned') {Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force}
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

choco install dotnet -y
choco install dotnet-6.0-sdk -y
