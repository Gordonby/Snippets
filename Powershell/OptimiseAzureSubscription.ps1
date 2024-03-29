Write-Output "Tag Subscription with Environment"
$context=Get-AzContext
$sub=Get-AzSubscription -SubscriptionId $context.Subscription -TenantId $context.Tenant
if ($sub.Tags["Environment"] -eq $null) {
  Update-AzTag -ResourceId "/subscriptions/$($sub.id)" -Tag @{"Environment"="Self-Learning"} -Operation Merge
}

Write-Output "Storage Accounts"
$storageAccounts=Get-AzStorageAccount
$storageAccounts | ?{$_.Kind -eq "Storage"} | % {Write-Output "Updating storage account $($_.StorageAccountName) to v2"; $_ | Set-AzStorageAccount -UpgradeToStorageV2}
$storageAccounts | ?{$_.MinimumTlsVersion -ne "TLS1_2"} | % {Write-Output "Updating storage account $($_.StorageAccountName) to TLS1.2"; $_ | Set-AzStorageAccount -MinimumTlsVersion TLS1_2}

Write-Output "Web Apps"
$webapps=Get-AzWebApp
$webapps | ? {$_.HttpsOnly -ne $true} | % {Write-Output "Updating web app $($_.Name) to HttpsOnly"; $_ | Set-AzWebApp -ResourceGroupName $_.ResourceGroup -HttpsOnly $true }

Write-Output "Checking for Bad NSG rules, should be using JIT"
$badPorts="22","3389","*", "445", "5985", "5986"
$nsgs=Get-AzNetworkSecurityGroup
$nsgSecurityRulesToRemove = $nsgs | % {$nsgName=$_.Name; $nsg=$_ ;$_.SecurityRules | ? {$_.Direction -eq "Inbound" -and $_.Access -eq "Allow" -and $_.Description -cnotlike "CSS Governance Security Rule*" -and $badPorts -contains $_.DestinationAddressPrefix} | select Name,DestinationAddressPrefix, @{Name="NetworkSecurityGroup"; Expression={$nsg}}}
if($nsgSecurityRulesToRemove.length > 0){$nsgSecurityRulesToRemove | %{Write-Output "Removing *bad nsg* rule $($_.Name) from $($_.NetworkSecurityGroup.Name)"; Remove-AzNetworkSecurityRuleConfig -Name $_.Name -NetworkSecurityGroup $_.NetworkSecurityGroup}} else {Write-Output "--No bad rules found"}

Write-Output "Verifying Subnet NSG Association"
$vnets=Get-AzVirtualNetwork
$vnets | %{Write-Output "Checking vnet $($_.Name)"; $_ | Get-AzVirtualNetworkSubnetConfig | %{ Write-Output "-- Subnet $($_.Name) NSG count=$($_.NetworkSecurityGroup.length)"}}
