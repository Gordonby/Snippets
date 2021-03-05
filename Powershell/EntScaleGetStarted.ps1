##########################################
# Create Service Principal as Root Owner #
##########################################

$rootscope = "/"
$mgScope = "/providers/Microsoft.Management/managementGroups/cntso"

#Create Service Principal and assign Owner role to Tenant root scope ("/")
$servicePrincipal = New-AzADServicePrincipal -Role Owner -Scope $rootscope -DisplayName AzOpsRoot

#Prettify output to print in the format for AZURE_CREDENTIALS
$servicePrincipalJson=[ordered]@{
    clientId = $servicePrincipal.ApplicationId
    displayName = $servicePrincipal.DisplayName
    name = $servicePrincipal.ServicePrincipalNames[1]
    clientSecret = [System.Net.NetworkCredential]::new("", $servicePrincipal.Secret).Password
    tenantId = (Get-AzContext).Tenant.Id
    subscriptionId = (Get-AzContext).Subscription.Id
} | ConvertTo-Json


########################################
# Configure the AzureAD directory role #
########################################

$azAADmod = Get-InstalledModule -Name AzureAD
If ($azAADmod -eq $NULL) {
    Write-Host "AzureAD module is not available"
    Write-Host "Attempting to install, but will only work if PowerShell was launched as Administrator"
    Install-Module -Name AzureAD
}

#Connect to Azure Active Directory
$AzureAdCred = Get-Credential
Connect-AzureAD -Credential $AzureAdCred

#Get AzOps Service Principal from Azure AD
$aadServicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq 'AzOps'"

#Get Azure AD Directory Role
$DirectoryRole = Get-AzureADDirectoryRole -Filter "DisplayName eq 'Directory Readers'"

if ($DirectoryRole -eq $NULL) {
    Write-Output "Directory Reader role not found. This usually occurs when the role has not yet been used in your directory"
    Write-Output "As a workaround, try assigning this role manually to the AzOps App in the Azure portal"
}
else {
    #Add service principal to Directory Role
    Add-AzureADDirectoryRoleMember -ObjectId $DirectoryRole.ObjectId -RefObjectId $aadServicePrincipal.ObjectId
}

$escapedServicePrincipalJson = $servicePrincipalJson.Replace('"','\"')
Write-Output $escapedServicePrincipalJson

{
    "clientId":  "ba6aa4bb-8019-4336-927d-c1f502989d97",
    "displayName":  "AzOps",
    "name":  "http://AzOps",
    "clientSecret":  "6de50002-c53a-4413-ac55-890882db22a0",
    "tenantId":  "b06e8efc-739c-414e-a10b-220b51db40b1",
    "subscriptionId":  "3f2fc8be-dbf2-44e1-84e8-321228974d35"
}


$DirectoryRole = Get-AzureADDirectoryRole | Where-Object  -Filter "DisplayName eq 'Directory Readers'"

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