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
$rgsToDelete = Get-AzResourceGroup -Tag @{'Cleanup'='PendingRGDelete'}

$rgsToDelete | % {
    $RG=$_
	$rgName=$RG.ResourceGroupName
    Write-Output "Deleting Resource Group = $rgName"

	# Tag the resource groups for a delayed cleanup
 	$rgsToDelete | Remove-AzResourceGroup -Force
}