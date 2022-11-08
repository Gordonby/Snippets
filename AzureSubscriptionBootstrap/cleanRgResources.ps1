try
{
    Disable-AzContextAutosave -Scope Process
    
	#System Managed
	$AzureContext = (Connect-AzAccount -Identity).context
    $AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

# Get all ARM resources from all resource groups
Write-Output "Get Resource Groups"
$rgsToPurge = Get-AzResourceGroup -Tag @{'Cleanup'='Automatically'}

$rgsToPurge | % {
    $RG=$_
	$rgName=$RG.ResourceGroupName
    Write-Output "Evaluating Resource Group = $rgName"

    #Get list of stuff to remove
    $rgResources = Get-AzResource -ResourceGroupName $RG.ResourceGroupName
    $rgResourceCount = $rgResources.length
    Write-Output "$rgResourceCount resources to remove from $rgName"

	if ($rgResources.length -gt 0) {

		$keyvaults = Get-AzResource -ResourceGroupName $RG.ResourceGroupName | ? {$_.ResourceType -eq "Microsoft.KeyVault/vaults"} 
		Write-Output "$($keyvaults.length) keyvaults to remove from $rgName"

		#Remove all but public ip addresses
		$rgResources | ? {$_.ResourceType -ne "Microsoft.Network/publicIPAddresses"} | Remove-AzResource -Force

		#Remove public ip addresses
		$rgResources | ? {$_.ResourceType -eq "Microsoft.Network/publicIPAddresses"} | Remove-AzResource -Force

		$rgResources = Get-AzResource -ResourceGroupName $RG.ResourceGroupName
		Write-Output "Post check. $($rgResources.length) resources left to remove from $rgName"

		if($rgResourceCount -gt 1 -and $rgResourceCount -eq $rgResources.length) {
			Write-Error "Issue deleting resources"
		}

		#Final run to clean other dependant resources in parent-child graph
		Get-AzResource -ResourceGroupName $RG.ResourceGroupName | Remove-AzResource -Force

		#Check for Soft Deleted KV's and remove
		if ($keyvaults.length -gt 0) {
			Write-Output "Purging KeyVaults" 
			$kvToPurge = $keyvaults | %{Get-AzKeyVault -VaultName $_.Name -InRemovedState -Location $_.Location}
			
			Write-Output "Post check. $($kvToPurge.length) key vaults to purge from $rgName"
			$kvToPurge | %{Remove-AzKeyVault -VaultName $_.VaultName -InRemovedState -Location $_.Location -Force}

			#Again
			$kvToPurge | %{Remove-AzKeyVault -VaultName $_.VaultName -InRemovedState -Location $_.Location -Force}
		}
	}

	#Remove invalid RBAC assignments
	Write-Output "Checking $rgName for Invalid RBAC assignments"
	$assignments=Get-AzRoleAssignment -ResourceGroupName $rgName -Debug
	Write-Output $assignments
	$invalidAssignments=$assignments | ? {$_.ObjectType -eq "Unknown" -and $_.Scope -like "*/$rgName"}
	if ($invalidAssignments -ne $null) {
		write-output "$invalidAssignments invalid RBAC assignments found, removing"
		$invalidAssignments | % { $_ | Remove-AzRoleAssignment}
	}
}