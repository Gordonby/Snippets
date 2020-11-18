#*********************************************************
#
# Copyright (c) Microsoft. All rights reserved.
# This code is licensed under the MIT License (MIT).
# THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
# ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
# IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
# PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
#
#*********************************************************

param
(
    [Parameter(Mandatory = $True)]
    [string] $SubscriptionId,

    [Parameter(Mandatory = $True)]
    [string] $ResourceGroupName,

    [Parameter(Mandatory = $True)]
    [ValidateSet("Australia East", "East US", "East US 2", "South Central US", "Southeast Asia", "West Europe", "West Central US", "West US 2")]
    [string] $Location,

    [Parameter(Mandatory = $True)]
    [string] $AdminUsername,

    [Parameter(Mandatory = $True)]
    [securestring] $AdminPassword
)

$ErrorActionPreference = "Stop"


###########################################################################
#
# Invoke-VmDeployment - Uses the .\IoTEdgeMlDemoVMTemplate.json template to 
# create a virtual machine.  Returns the name of the virtual machine.
# 
Function Invoke-VmDeployment($resourceGroup) {
    # Create a unique deployment name
    $randomSuffix = -join ((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object {[char]$_})
    $deploymentName = "IotEdgeMlDemoVm-$randomSuffix"
    $params = @{
        "location"      = $Location
        "adminUsername" = $AdminUsername
        "adminPassword" = $AdminPassword
    }

    Write-Host @"
`nStarting deployment of the demo VM which may take a while.
Progress can be monitored from the Azure Portal (http://portal.azure.com).
    1. Find the resource group $ResourceGroupName.
    2. In the Deployments page open deployment $deploymentName.
"@

    $deployment = New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroup.ResourceGroupName -TemplateFile '.\IoTEdgeMLDemoVMTemplate.json' -TemplateParameterObject $params
    return $deployment.Outputs.vmName.value
}

###########################################################################
#
# Enable-HyperV -- Uses the vmname to enable Hyper-V on the VM.
# 
Function Install-Software($vmName) {
    $vmInfo = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName -Status
    foreach ($state in $vmInfo.Statuses) {
        if (!$state.Code.StartsWith("PowerState")) {
            continue
        }

        if ($state.Code.Contains("running")) {
            Write-Host "VM $vmName is running"
            break
        }
        else {
            Write-Host "Starting VM $vmName"
            Start-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName
        }
    }

    Write-Host "`nEnabling Hyper-V in Windows on Azure VM..."

    Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -Name $vmName -CommandId "RunPowerShellScript" -ScriptPath '.\Enable-HyperV.ps1' 2>&1>$null
    Write-Host "`nInstalling Chocolatey on Azure VM..."
    Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -Name $vmName -CommandId "RunPowerShellScript" -ScriptPath '.\Install-Chocolatey.ps1' 2>&1>$null
    Write-Host "`nInstalling necessary software on Azure VM..."
    Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -Name $vmName -CommandId "RunPowerShellScript" -ScriptPath '.\Install-DevMachineSoftware.ps1' -Parameter @{ "AdminUserName" = $AdminUsername; } 2>&1>$null
  
    Write-Host "`nRestarting the VM..."
    Restart-AzVM -Id "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName" 2>&1>$null
}

###########################################################################
#
# Export-RdpFile -- Uses the vmname to find the virutal machine's FQDN then 
# writes an RDP file to rdpFilePath.
# 
Function Export-RdpFile($vmName, $rdpFilePath) {
    
    Write-Host "`nWriting the VM RDP file to $rdpFilePath"
    $vmFQDN = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName | Get-AzPublicIpAddress).DnsSettings.FQDN 3> $null

    $rdpContent = @"
full address:s:$($vmFQDN):3389
prompt for credentials:i:1
username:s:$vmName\$AdminUsername
"@
    
    Set-Content -Path $rdpFilePath -Value $rdpContent
}

###########################################################################
#
# Main 
# 

Write-Host "Creating Resource Group: $ResourceGroupName"
$resourceGroup = New-AzResourceGroup -name $ResourceGroupName -Location $Location

$vmName = Invoke-VmDeployment $resourceGroup

Install-Software $vmName
$desktop = [Environment]::GetFolderPath("Desktop")
$rdpFilePath = [IO.Path]::Combine($desktop, "$vmName.rdp")
Export-RdpFile $vmName $rdpFilePath

Write-Host @"

The VM is ready.
Visit the Azure Portal (http://portal.azure.com).
    - Virtual machine name: $vmName
    - Resource group: $ResourceGroupName

Use the RDP file: $rdpFilePath to connect to the virtual machine.

"@
Write-Warning "Please note this VM was configured with a shutdown schedule. Review it on the VM blade to confirm the settings work for you."
