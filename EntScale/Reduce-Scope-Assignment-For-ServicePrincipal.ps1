#Define management group variables
$devBootstrapPrefix="codev"
$prodBootstrapPrefix="coprd"



#Define management group ids
$devMgScope = "/providers/Microsoft.Management/managementGroups/$devBootstrapPrefix"
$prodMgScope = "/providers/Microsoft.Management/managementGroups/$prodBootstrapPrefix"

#Retrieve the Service Principal
$sp = Get-AzADServicePrincipal -DisplayName "AzOpsRootReader"

#Remove any Root scope assignments that have been made for this Service Principal
Get-AzRoleAssignment -Scope "/" -ObjectId $sp.Id | % {
    Write-Output "Removing role $($_.RoleDefinitionId) "
    Remove-AzRoleAssignment -Scope "/" -ObjectId $_.ObjectId -RoleDefinitionId $_.RoleDefinitionId
}

#Make new, scoped Role Assignments
New-AzRoleAssignment -Scope $devMgScope -RoleDefinitionName 'Reader' -ObjectId $sp.Id
New-AzRoleAssignment -Scope $prodMgScope -RoleDefinitionName 'Reader' -ObjectId $sp.Id