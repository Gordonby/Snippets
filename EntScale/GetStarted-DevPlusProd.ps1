#################
# Prerequisites #
#################

# 1. You need to have completed a bootstrap installation for "test"/"dev" of Enterprise-Scale
# 2. You need to have completed a bootstrap installation for "prod" of Enterprise-Scale

$devBootstrapPrefix="codev"
$prodBootstrapPrefix="coprd"

#############################
# Create Service Principals #
#############################

$rootscope = "/"
$devMgScope = "/providers/Microsoft.Management/managementGroups/$devBootstrapPrefix"
$prodMgScope = "/providers/Microsoft.Management/managementGroups/$prodBootstrapPrefix"

#Create Service Principal and assign Owner role to the right scopes
$servicePrincipals=@()
$servicePrincipals += New-AzADServicePrincipal -Role Reader -Scope $rootscope -DisplayName AzOpsRootReader
$servicePrincipals += New-AzADServicePrincipal -Role Owner -Scope $devMgScope -DisplayName AzOpsDev
$servicePrincipals += New-AzADServicePrincipal -Role Owner -Scope $prodMgScope -DisplayName AzOpsProd
#$servicePrincipals += New-AzADServicePrincipal -DisplayName AzOpsCredRotateHelper

$servicePrincipals | % {
    #Provide reader access to the current subscription.
    #AzOps requires Service Principals have at least some RBAC on a default subscription
    New-AzRoleAssignment -ObjectId $_.Id -RoleDefinitionName Reader -Scope "/subscriptions/$((Get-AzContext).Subscription.Id)"

    #Prettify output to print in the format for AZURE_CREDENTIALS
    $spDevJson=[ordered]@{
        clientId = $_.ApplicationId
        displayName = $_.DisplayName
        name = $_.ServicePrincipalNames[1]
        clientSecret = [System.Net.NetworkCredential]::new("", $_.Secret).Password
        tenantId = (Get-AzContext).Tenant.Id
        subscriptionId = (Get-AzContext).Subscription.Id
    } | ConvertTo-Json
    $spDevJsonE = $spDevJson.Replace('"','\"')
    Write-Output $spDevJsonE
}


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
$aadServicePrincipals = Get-AzureADServicePrincipal -Filter "DisplayName eq 'AzOpsRootReader'"

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