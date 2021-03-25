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
$readerSP = New-AzADServicePrincipal -DisplayName AzOpsReader6
New-AzRoleAssignment -Scope $devMgScope -RoleDefinitionName 'Reader' -ObjectId $readerSP.Id
New-AzRoleAssignment -Scope $prodMgScope -RoleDefinitionName 'Reader' -ObjectId $readerSP.Id

#$rotaterSP = New-AzADServicePrincipal -DisplayName AzOpsCredRotateHelper
$devSP = New-AzADServicePrincipal -Role Owner -Scope $devMgScope -DisplayName AzOpsDev6
$prodSP = New-AzADServicePrincipal -Role Owner -Scope $prodMgScope -DisplayName AzOpsProd6

#Provide reader access to the current subscription.
#AzOps requires Service Principals have at least some RBAC on a default subscription, the current subscription context is used for simplicity.
New-AzRoleAssignment -ObjectId $readerSP.Id -RoleDefinitionName Reader -Scope "/subscriptions/$((Get-AzContext).Subscription.Id)"
New-AzRoleAssignment -ObjectId $devSP.Id -RoleDefinitionName Reader -Scope "/subscriptions/$((Get-AzContext).Subscription.Id)"
New-AzRoleAssignment -ObjectId $prodSP.Id -RoleDefinitionName Reader -Scope "/subscriptions/$((Get-AzContext).Subscription.Id)"

###############################################################
# Specify function to easily get Json from a ServicePrincipal #
###############################################################
function GetJsonFromSP($SP, $removeCrlf=$true) {
    #Prettify output to print in the format for AZURE_CREDENTIALS
    $spDevJson=[ordered]@{
        clientId = $SP.ApplicationId
        displayName = $SP.DisplayName
        name = $SP.ServicePrincipalNames[1]
        clientSecret = [System.Net.NetworkCredential]::new("", $SP.Secret).Password
        tenantId = (Get-AzContext).Tenant.Id
        subscriptionId = (Get-AzContext).Subscription.Id
    } | ConvertTo-Json
    $spDevJsonE = $spDevJson.Replace('"','\"')
    
    if($removeCrlf -eq $true) {$spDevJsonE= $spDevJsonE -replace "`t|`n|`r",""}
    return $spDevJsonE
}

######################################
# Optionally, Output SPN's to screen #
######################################
Write-Output "$(GetJsonFromSP $readerSP $false)"
Write-Output "$(GetJsonFromSP $prodSP $false)"
Write-Output "$(GetJsonFromSP $devSP $false)" 

###################################################
# Update existing Azure DevOps Pipeline Variables #
###################################################
$org="https://gdoggmsft.visualstudio.com/"
$project="EntScaleT4"

az extension add -n "azure-devops"
az login --use-device-code #az devops login --organization "$org" 
az devops configure --defaults organization=$org project=$project

az pipelines variable update --name AZURE_CREDENTIALS --pipeline-name AzOps-Pull --secret true --value "$(GetJsonFromSP($readerSP))"
az pipelines variable update --name AZURE_CREDENTIALS --pipeline-name AzOps-Prod-Push --secret true --value "$(GetJsonFromSP($prodSP))"
az pipelines variable update --name AZURE_CREDENTIALS --pipeline-name AzOps-Dev-Push --secret true --value "$(GetJsonFromSP($devSP))"

#az pipelines variable-group create --name "AZURE_CREDENTIALS" --variables "$devBootstrapPrefix=$(GetJsonFromSP($devSP)) $prodBootstrapPrefix=$(GetJsonFromSP($prodSP))"

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
$aadServicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq 'AzOpsReader'"

#Get Azure AD Directory Role
$DirectoryRole = Get-AzureADDirectoryRole -Filter "DisplayName eq 'Directory Readers'"
#$DirectoryRole = Get-AzureADDirectoryRole | Where-Object {$_.DisplayName -eq "Directory Readers"} #If the line above doesn't work with the Filter param, then do this.

if ($DirectoryRole -eq $NULL) {
    Write-Output "Directory Reader role not found. This usually occurs when the role has not yet been used in your directory"
    Write-Output "As a workaround, try assigning this role manually to the AzOps App in the Azure portal"
}
else {
    #Add service principal to Directory Role
    Add-AzureADDirectoryRoleMember -ObjectId $DirectoryRole.ObjectId -RefObjectId $aadServicePrincipal.ObjectId
}



