
Removes Recovery Services Vaults from a Specific Resource Group
In this script, only AzureStorage File share protection is expected.

> Warning : Data will be removed!


```powershell
$vaults=Get-AzRecoveryServicesVault -ResourceGroupName innerloop

$vaults | % { 
  Write-Output "Deleting vault process for $($_.Name)"
  
  $_ | Set-AzRecoveryServicesVaultContext
  Write-Output "- Context set"
  
  Write-Output "- Removing AzStorage protection policies"
  Get-AzRecoveryServicesBackupProtectionPolicy -BackupManagementType AzureStorage -WorkloadType AzureFiles | % { Remove-AzRecoveryServicesBackupProtectionPolicy $_.Name -force }
  
  Write-Output "- Disabling AzStorage backup items"
  Get-AzRecoveryServicesBackupItem -BackupManagementType AzureStorage -WorkloadType AzureFiles | Disable-AzRecoveryServicesBackupProtection -RemoveRecoveryPoints -Force 
  
  Write-Output "- Unregistering containers"
  Get-AzRecoveryServicesBackupContainer -ContainerType AzureStorage | % { Unregister-AzRecoveryServicesBackupContainer -Container $_  -Force }
  
  Write-Output "- Deleting vault"
  $_ | Remove-AzRecoveryServicesVault
}
```

![image](https://user-images.githubusercontent.com/17914476/206445697-bc42105f-1b1d-424c-a279-a451eb91efed.png)
