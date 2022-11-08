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
Write-Output "Get Resource Groups to tag"
$rgsToPurge = Get-AzResourceGroup | ? {$_.Tags.Count -eq 0}
Write-Verbose $rgsToPurge

# Tag the resource groups for a delayed cleanup
 $rgsToPurge | Set-AzResourceGroup -Tag @{Cleanup="PendingRGDelete"}

# Optionally, Write to a Log Analytics workspace
