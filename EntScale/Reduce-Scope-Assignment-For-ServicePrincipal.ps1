#Define the new management group scope
$mgScope = "/providers/Microsoft.Management/managementGroups/cntso"

#Retrieve the Service Principal
$sp = Get-AzADServicePrincipal -DisplayName "AzOpsCanary3"

#Remove any Root scope assignments that have been made for this Service Principal
Get-AzRoleAssignment -Scope "/" -ObjectId $sp.Id | % {
    Write-Output "Removing role $($_.RoleDefinitionId)"
    Remove-AzRoleAssignment -Scope "/" -ObjectId $_.ObjectId -RoleDefinitionId $_.RoleDefinitionId
}

#Make a new, scoped Role Assignment
New-AzRoleAssignment -Scope $mgScope -RoleDefinitionName 'Owner' -ObjectId $sp.Id