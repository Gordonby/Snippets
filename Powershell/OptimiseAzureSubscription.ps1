
Write-Output "Storage Accounts"
$storageAccounts=Get-AzStorageAccount
$storageAccounts | ?{$_.Kind -eq "Storage"} | % {Write-Output "Updating storage account $($_.StorageAccountName) to v2"; $_ | Set-AzStorageAccount -UpgradeToStorageV2}
$storageAccounts | ?{$_.MinimumTlsVersion -ne "TLS1_2"} | % {Write-Output "Updating storage account $($_.StorageAccountName) to TLS1.2"; $_ | Set-AzStorageAccount -MinimumTlsVersion TLS1_2}

