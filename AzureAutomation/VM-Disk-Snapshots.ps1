<#
    .SYNOPSIS
        This Azure Automation runbook automates the scheduled shutdown and startup of AKS Clusters in an Azure subscription. 

    .DESCRIPTION
        Loops over a resource group, finding VM's, shutting them down and then initiating disk snapshots

    .PARAMETER ResourceGroupName
        The name of the ResourceGroup where to loop through

    .INPUTS
        None.

    .OUTPUTS
        Human-readable informational and error messages produced during the job. Not intended to be consumed by another runbook.
#>

Param(
    	[parameter(Mandatory=$true)]
    	[String] $ResourceGroupName
)
	
try
{
	Disable-AzContextAutosave -Scope Process
		
	#System Managed Identity
	Write-Output "Logging into Azure using System Managed Identity"
	$AzureContext = (Connect-AzAccount -Identity).context
	$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
}
catch {
	Write-Error -Message $_.Exception
	throw $_.Exception
}

$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
