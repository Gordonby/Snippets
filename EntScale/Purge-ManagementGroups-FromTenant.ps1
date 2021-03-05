#Intended to clean up a subscription after deploying the "In a box" EntScale implementation to your MSDN Azure Sub's.
$ErrorActionPreference = "Stop"

$tenantId = "b06e8efc-739c-414e-a10b-220b51db40b1"


Connect-AzAccount -Tenant $tenantId 

#Gather management group information
$managementgroups = Get-AzManagementGroup
$RootManagementGroup = $managementgroups | Where-Object{$_.Name -eq $tenantId }

$topLevelManagementGroup = $managementgroups[1]
$topLevelGroupName = $topLevelManagementGroup.DisplayName
$expandedTopLevelGroup = Get-AzManagementGroup -GroupName $topLevelGroupName -Expand

if ($expandedTopLevelGroup.ParentId = $RootManagementGroup.Id)
{
    Write-Output "Confirmed, found top level"
}

Write-Output "Move subscriptions to root"
$subscriptions=Get-AzSubscription -TenantId $tenantId
$subscriptions | % {
    Write-Output "-- Moving subscription $($_.Name)"
    New-AzManagementGroupSubscription -GroupName $RootManagementGroup.Name -SubscriptionId $_.Id
}

Write-Output "Removing all Azure resources and resource groups"
$recursiveMgmtStructure=Get-AzManagementGroup -GroupName $topLevelGroupName -Expand -Recurse

$mgmtGroups=$managementgroups | Where-Object Name -NE $RootManagementGroup.Name | select -ExpandProperty Name
[array]::Reverse($mgmtGroups)

$ErrorActionPreference = "SilentlyContinue"
Write-Host "Removing all Management Groups including the Enterprise Scale Top Level Group"
$mgmtGroups | % {
    Write-Host "Deleting Management Group:" $_
    Remove-AzManagementGroup -GroupName $_
}
$managementgroups = Get-AzManagementGroup
$managementgroups | fl

Write-Output "Removing all Azure resources and resource groups"
ForEach ($subscription in $subscriptions) {
    if($subscription.Name -like "*Contoso EntScale") {
        Write-Host "Purging subscription $($subscription.Name)"
        Set-AzContext -Subscription $subscription.Id
        $resources = Get-AzResourceGroup
        $resources | ?{$_.ResourceGroupName -notlike 'cloud-shell*'} | % {
            Write-Host "--Deleting RG: " $_.ResourceGroupName "..."
            Remove-AzResourceGroup -Name $_.ResourceGroupName -Force
        }
    }
    else {
        Write-Host "Skipping subscription: $($subscription.Name)"
    }
}

Write-Output "Investigating AzOps Service Principals"
Write-Output "Remember to clean up them up.  Use these statements"
$sps = Get-AzADServicePrincipal -DisplayNameBeginsWith 'AzOps'
$sps | % {

    Write-Output "Remove-AzADServicePrincipal -ObjectId $($_.Id) -force `#$($_.DisplayName)"  
}

Write-Output "Investigating AzOps Apps"
Write-Output "Remember to clean up them up.  Use these statements"
$appregs = Get-AzADApplication -DisplayNameStartWith 'AzOps'
$appregs | % {

    #Write-Output "Remove-AzADAppCredential -ObjectId $($_.ObjectId) -force;  `#$($_.DisplayName) "  
    Write-Output "Remove-AzADApplication -ObjectId $($_.ObjectId) -force;  `#$($_.DisplayName) "  
}


#TODO: Go delete/disable your pipelines.
#TODO: Archive your repo.

