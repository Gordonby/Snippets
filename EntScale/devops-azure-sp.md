# AZ AD CLI

These code snippets show how to create a service principal, that is able to be used in Azure DevOps which can query it's own attributes such as Application ObjectID. It's also able to reset its own secrets, which can be very useful in an autonomous key rotation scenario.

## The API's

There are 2 API's to interact with Azure Active Directory.
1. Microsoft Graph
2. Azure Active Directory Graph

The Azure Active Directory Graph is on a depreacation path, but is still leveraged in some of the AZ CLI commands as well as some of the other Microsoft libararies for AAD.
This means both API's should be granted permission in order to avoid future disruption.

At time of writing, the AZ CLI version *2.28.0* is not using the Microsoft Graph for the `az ad app show` command (amongst others). Therefore if you do not grant the AAD Graph API permission, an error will be encountered. `Insufficient privileges to complete the operation.`

## The scripts

1. Create a Service Principal with no RBAC
```powershell
$SpName="spbootstrap"
$Sp=az ad sp create-for-rbac -n $SpName --skip-assignment -o json | ConvertFrom-Json
```

2. Make the SP an owner of it's App counterpart (otherwise it won't be able to read the Application ObjectId later)

```powershell
#Microsoft Graph API
$MsGraphApi="00000003-0000-0000-c000-000000000000"
$MSGraphRoles=az ad sp show --id $MsGraphApi -o json | ConvertFrom-Json
$MsGraphApiRoleId=$MsGraphRoles.appRoles | select value, id | Sort-Object value | where-object value -eq "Application.ReadWrite.OwnedBy" | select -expandproperty id 

#Azure Active Directory Graph API (being deprecated, but still used by some official Microsoft libraries)
$AadGraphApi="00000002-0000-0000-c000-000000000000"
$AadGraphRoles=az ad sp show --id $AadGraphApi -o json | ConvertFrom-Json
$AadGraphApiRoleId=$AadGraphRoles.appRoles | select value, id | Sort-Object value | where-object value -eq "Application.ReadWrite.OwnedBy" | select -expandproperty id 


$AppId= $Sp | select -expandproperty appId
$SpObjId=az ad sp show --id $AppId --query objectId -o tsv
az ad app owner add --id $AppId --owner-object-id $SpObjId
az ad app permission add --id $AppId --api $MsGraphApi --api-permissions "$MsGraphApiRoleId=Role"
az ad app permission add --id $AppId --api $AadGraphApi --api-permissions "$AadGraphApiRoleId=Role"
az ad app permission list --id $AppId
```

3. Grant admin consent for the Application API Permissions in the Azure Portal.
https://docs.microsoft.com/en-us/azure/active-directory/manage-apps/grant-admin-consent#grant-admin-consent-from-the-azure-portal

4. Create a Service Connection in Azure DevOps (as per this [post](https://gordon.byers.me/azure/create-empty-azure-azuredevops-serviceconnections.html)) as an `Azure Resource Manager` `Service Principal (Manual)`
5. Create a Pipeline in Azure DevOps, adding a Azure CLI task

```yaml
trigger: none

pool:
  vmImage: ubuntu-latest

steps:
      
- task: AzureCLI@2
  inputs:
    azureSubscription: 'BootstrapSP'
    scriptType: 'pscore'
    scriptLocation: 'inlineScript'
    addSpnToEnvironment: true
    inlineScript: |     
      Write-Output "Get App ObjectId from Azure AD"
      $appObjId = az ad app show --id $env:servicePrincipalId --query objectId -o tsv
```
