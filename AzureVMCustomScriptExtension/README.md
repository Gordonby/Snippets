A collection of scripts that can be leveraged;

- During creation of an Azure Virtual Machine
- From within a Virtual Machine or local workstation

In order to fulfill easy workstation configuration, just run using the AzureVMCustomScript extension or in a local PowerShell window (admin priv. required).

eg. Here's how i've used the PowerShell files to setup a new laptop;

### Windows PowerShell (as admin)

```powershell
If ((Get-ExecutionPolicy) -ne 'RemoteSigned') {Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force}

#Install developer fundamental applications
Invoke-WebRequest https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureVMCustomScriptExtension/DevFundamentals.ps1 -UseBasicParsing | Invoke-Expression

# Install dotnet developer persona applications
#Invoke-WebRequest https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureVMCustomScriptExtension/devdotnet.ps1 -UseBasicParsing | Invoke-Expression

Restart-Computer

```

### Pwsh (as admin)

```powershell
If ((Get-ExecutionPolicy) -ne 'RemoteSigned') {Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force}

# Create a well configured PowerShell Profile file for common aliases, etc.
Invoke-WebRequest https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureVMCustomScriptExtension/PowerShellProfile.ps1 -UseBasicParsing | Invoke-Expression

# Windows Subsystem for linux
Invoke-WebRequest https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureVMCustomScriptExtension/wsl.ps1 -UseBasicParsing | Invoke-Expression

```

### WSL Distro's

```bash
sudo apt update
```

### Manual steps

(These should be automation)

1. Configure Docker-Desktop settings. Untick `Start Docker Desktop when you log in`
1. Open VSCode, Enable Settings Sync, Sign in, Wait
1. Open GitHub, Sign in, Follow Configure Git prompts
2. 
