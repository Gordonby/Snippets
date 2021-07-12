# Creates the Service Principals, and adds to ADO for a multi-environment Enterprise Scale deployment

#################
# Prerequisites #
#################

# 1. You need to have completed a Reference Implementation for "canary/dev" of Enterprise-Scale
# 2. You need to have completed a Reference Implementation for "prod" of Enterprise-Scale
# (ref: https://github.com/Azure/Enterprise-Scale/blob/main/docs/EnterpriseScale-Deploy-reference-implentations.md)

$devBootstrapPrefix="canary"
$prodBootstrapPrefix="prod"

# 3. You need an existing Azure DevOps project created

$org="https://gdoggmsft.visualstudio.com/"
$project="EntScaleT9"
#$org="https://dev.azure.com/mscet"
#$project="CAE-AzOps-MultiEnv"

###########################
# Tenant Login and Verify #
###########################

#It's best to check that we're operating in the right tenant where your CANARY and PROD Management groups are.
#Set these to represent your tenantId and expected default subscriptionId
$tenantId = "b06e8efc-739c-414e-a10b-220b51db40b1"
$subId="3f2fc8be-dbf2-44e1-84e8-321228974d35"

Connect-AzAccount -Tenant $tenantId 
$currentContext=Get-AzContext
If ($tenantId -eq $currentContext.Tenant -and $subId -eq $currentContext.Subscription) {
    #All good.
    Write-Output "Tenant/Subscription is as expected"
}
else {
    Write-Error "Operating in unexpected tenant"
}

#############################
# Create Service Principals #
#############################


$devMgScope = "/providers/Microsoft.Management/managementGroups/$devBootstrapPrefix"
$prodMgScope = "/providers/Microsoft.Management/managementGroups/$prodBootstrapPrefix"

$devSP = New-AzADServicePrincipal -Role Owner -Scope $devMgScope -DisplayName AzOpsCanary4
$prodSP = New-AzADServicePrincipal -Role Owner -Scope $prodMgScope -DisplayName AzOpsProd4

# Provide reader access to the current subscription.
# AzOps (well the PowerShell Connect-Az cmdlet) requires Service Principals have at least some RBAC on a default subscription, the current subscription context is used for simplicity. You can be explict for these ID's if required.
# It's   hopeful this requirement will go away soon
#New-AzRoleAssignment -ObjectId $devSP.Id -RoleDefinitionName Reader -Scope "/subscriptions/$((Get-AzContext).Subscription.Id)"
#New-AzRoleAssignment -ObjectId $prodSP.Id -RoleDefinitionName Reader -Scope "/subscriptions/$((Get-AzContext).Subscription.Id)"

###############################################################
# Specify function to easily get Json from a ServicePrincipal #
###############################################################
function GetJsonFromSP($SP, $removeCrlf=$true, $escapeCharsForAzCli=$true) {
    #Used when storing SP creds inside a single Pipeline variable as Json

    $spDevJson=[ordered]@{
        clientId = $SP.ApplicationId
        displayName = $SP.DisplayName
        name = $SP.ServicePrincipalNames[1]
        clientSecret = [System.Net.NetworkCredential]::new("", $SP.Secret).Password
        tenantId = (Get-AzContext).Tenant.Id
    } | ConvertTo-Json
    $spDevJsonE = $spDevJson.Replace('"','\\\"')

    if ($escapeCharsForAzCli) {$spDevJsonE = $spDevJson.Replace('"','\\\"')}
    else {$spDevJsonE = $spDevJson.Replace('"','\"')}
    
    if($removeCrlf -eq $true) {$spDevJsonE= $spDevJsonE -replace "`t|`n|`r",""}
    return $spDevJsonE
}

######################################
# OPTIONALLY, Output SPN's to screen #
######################################
Write-Output "$(GetJsonFromSP $prodSP $false $false)"
Write-Output "$(GetJsonFromSP $devSP $false $false)" 

#############################################
# Specify function to create variable group #
#############################################
function create-devops-variablegroup-forSP($name, $sp, $secretOverride) {
    #Used when storing SP creds inside a Variable Group

    $clientId = $sp.ApplicationId.Guid
    
    $tenantId = (Get-AzContext).Tenant.Id

    if ($secretOverride) {
        #Use a specifically provided secret value
        $secret=[System.Net.NetworkCredential]::new("", $secretOverride).Password
    } else {
        #Try and read from the SP object, this only works when the SP was created.
        $secret=[System.Net.NetworkCredential]::new("", $sp.Secret).Password
    }

    $groupId = az pipelines variable-group create --name $name --variables "DisplayName=$($sp.DisplayName)" --query id
    az pipelines variable-group variable create --group-id $groupId --name ARM_CLIENT_ID --value $clientId 
    az pipelines variable-group variable create --group-id $groupId --name ARM_CLIENT_SECRET --value $secret --secret
    az pipelines variable-group variable create --group-id $groupId --name ARM_TENANT_ID --value $tenantId 
}

########################
# Azure DevOps - Login #
########################
az extension add -n "azure-devops"
az login --use-device-code #Even though we're authenticated for PowerShell, we now switch to Az so need to auth again. T
az devops configure --defaults organization=$org project=$project

#########################################
# Azure DevOps - Create Variable Groups #
#########################################
Write-Output "Testing Extension can see project $project"
$adoprojtest=az devops project show -p $project --query "[id, name]" -o tsv
if($null -eq $adoprojtest) {Write-Output "Issue connecting to ADO"} else {Write-Output $adoprojtest}

create-devops-variablegroup-forSP "AZURECREDENTIALS_CANARY" $devSP
create-devops-variablegroup-forSP "AZURECREDENTIALS_PROD" $prodSP

####################################################################
# Configure the AzureAD directory role                             #
# (This is used to resolve AAD object names from their Ids)        #
# (It requires another login as we're using a different cmdlet)    #
# (HereBeDragons, am sure it'll get better in the future #msgraph) #
####################################################################

$azAADmod = Get-InstalledModule -Name AzureAD
If ($null -eq $azAADmod) {
    Write-Host "AzureAD module is not available"
    Write-Host "Attempting to install, but will only work if PowerShell was launched as Administrator"
    Install-Module -Name AzureAD
}

#Connect to Azure Active Directory
$AzureAdCred = Get-Credential #Even though we're authenticated for Azure-PowerShell, AzureAd is a different module and we require another auth.
Connect-AzureAD -Credential $AzureAdCred

#Get AzOps Service Principal from Azure AD
$devServicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq '$($devSP.DisplayName)'"
$prodServicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq '$($prodSP.DisplayName)'"

#Get Azure AD Directory Role
#$DirectoryRole = Get-AzureADDirectoryRole -Filter "DisplayName eq 'Directory Readers'" #The filter option does not seem to work in CloudShell.  Using an alternate approach
$DirectoryRole = Get-AzureADDirectoryRole | Where-Object {$_.DisplayName -eq "Directory Readers"}

if ($DirectoryRole -eq $NULL) {
    Write-Output "Directory Reader role not found. This usually occurs when the role has not yet been used in your directory"
    Write-Output "As a workaround, try assigning this role manually to the AzOps App in the Azure portal"
}
else {
    #Add service principal to Directory Role
    Add-AzureADDirectoryRoleMember -ObjectId $DirectoryRole.ObjectId -RefObjectId $devServicePrincipal.ObjectId
    Add-AzureADDirectoryRoleMember -ObjectId $DirectoryRole.ObjectId -RefObjectId $prodServicePrincipal.ObjectId
}


##################################################
# Manual SP secret rotation code                 #
# - Leverages Azure DevOps connection made above #
# - Leverages Azure Context made above           #
##################################################

$CanarySp = Get-AzADServicePrincipal -DisplayName AzOpsCanary
$newCanaryCred = $CanarySp | New-AzADServicePrincipalCredential
#create-devops-variablegroup-forSP -name AzOpsCanary -sp $CanarySp -secretOverride $newCanaryCred.Secret
$CanaryGroupId = az pipelines variable-group list --query "[?name=='AZURECREDENTIALS_CANARY'].{Id:id}" -o tsv
az pipelines variable-group variable update --group-id $CanaryGroupId --name ARM_CLIENT_SECRET --value [System.Net.NetworkCredential]::new("", $newCanaryCred.Secret).Password  --secret

$ProdSp = Get-AzADServicePrincipal -DisplayName AzOpsProd
$newProdCred = $ProdSp | New-AzADServicePrincipalCredential
#create-devops-variablegroup-forSP -name AzOpsCanary -sp $CanarySp -secretOverride $newCanaryCred.Secret
$ProdGroupId = az pipelines variable-group list --query "[?name=='AZURECREDENTIALS_PROD'].{Id:id}" -o tsv
az pipelines variable-group variable update --group-id $ProdGroupId --name ARM_CLIENT_SECRET --value [System.Net.NetworkCredential]::new("", $newProdCred.Secret).Password  --secret

#Optional, write out to screen for manual updating in ADO
Write-Output "AZURECREDENTIALS_CANARY $([System.Net.NetworkCredential]::new('', $newCanaryCred.Secret).Password)" 
Write-Output "AZURECREDENTIALS_PROD $([System.Net.NetworkCredential]::new('', $newProdCred.Secret).Password)" 

#Optional, use these in the event the variable groups are destroyed and need recreated
#create-devops-variablegroup-forSP "AZURECREDENTIALS_CANARY" $CanarySp $([System.Net.NetworkCredential]::new("", $newCanaryCred.Secret).Password)
#create-devops-variablegroup-forSP "AZURECREDENTIALS_PROD" $ProdSp $([System.Net.NetworkCredential]::new("", $newProdCred.Secret).Password)