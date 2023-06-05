A collection of scripts that can be leveraged;

- During creation of an Azure Virtual Machine
- From within a Virtual Machine or local workstation

In order to fulfill easy workstation configuration, just run using the AzureVMCustomScript extension or in a local PowerShell window (admin priv. required).

## Local Setup

These steps represent what is run on my local workstation when a fresh setup is required.

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

# Setup VSCode extensions
Invoke-WebRequest  https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureVMCustomScriptExtension/VsCodeExtensions.ps1 -UseBasicParsing | Invoke-Expression

# Windows Subsystem for linux
Invoke-WebRequest https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureVMCustomScriptExtension/wsl.ps1 -UseBasicParsing | Invoke-Expression

```

### WSL Distro's

```bash
sudo apt update
```

### Manual steps

(These should be automation.. at some point, but might need registry hacks)

1. Configure Docker-Desktop settings. Untick `Start Docker Desktop when you log in`
1. Configure Docker-Desktop WSL integration. Settings > Resources > WSL Integration.
1. Open VSCode, Enable Settings Sync, Sign in, Wait
1. Open GitHub, Sign in, Follow Configure Git prompts
1. Install Kusto Explorer: https://aka.ms/ke
1. Install brm : `dotnet tool install --global Azure.Bicep.RegistryModuleTool`

#### Hardware specific
1. Download and install the Microsoft Mouse and Keyboard Center software (MS Precision mouse) https://go.microsoft.com/fwlink/?linkid=849754


#### Windows personalisation
1. Change the mouse pointer style to custom, turqoise colour and size 2.
2. Add a new Edge browser profile for other profiles (eg. independant azure tenant, other GitHub account)
3. Windows terminal pin to start

