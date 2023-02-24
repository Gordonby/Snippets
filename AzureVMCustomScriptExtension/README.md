A collection of scripts that can be leveraged;

- During creation of an Azure Virtual Machine
- From within a Virtual Machine or local workstation

In order to fulfill easy workstation configuration.

eg.

```powershell
If ((Get-ExecutionPolicy) -ne 'RemoteSigned') {Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force}

#Install developer fundamental applications
Invoke-WebRequest https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureVMCustomScriptExtension/DevFundamentals.ps1 -UseBasicParsing | Invoke-Expression

# Install dotnet developer persona applications
#Invoke-WebRequest https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureVMCustomScriptExtension/devdotnet.ps1 -UseBasicParsing | Invoke-Expression

# Create a well configured PowerShell Profile file for common aliases, etc.
https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureVMCustomScriptExtension/PowerShellProfile.ps1
```
