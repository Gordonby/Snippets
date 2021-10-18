## Equipping Azure DevOps with a Service Principal

1. Create a Service Principal with no RBAC
```powershell
$SpName="spbootstrap"
$Sp=az ad sp create-for-rbac -n $SpName --skip-assignment -o json | ConvertFrom-Json
```

2. Make the SP an owner of it's App counterpart (otherwise it won't be able to read the Application ObjectId later)

```powershell
$MsGraphApi="00000003-0000-0000-c000-000000000000"
$MSGraphRoles=az ad sp show --id $MsGraphApi -o json | ConvertFrom-Json
$MsGraphApiRoleId=$MsGraphRoles.appRoles | select value, id | Sort-Object value | where-object value -eq "Application.ReadWrite.OwnedBy" | select -expandproperty id 
#$MsGraphApiRoleId="18a4783c-866b-4cc7-a460-3d5e5662c884" #Application.ReadWriteOwnedBy

$AadGraphApi="00000002-0000-0000-c000-000000000000"
$AadGraphRoles=az ad sp show --id $AadGraphApi -o json | ConvertFrom-Json
$AadGraphApiRoleId=$AadGraphRoles.appRoles | select value, id | Sort-Object value | where-object value -eq "Application.ReadWrite.OwnedBy" | select -expandproperty id 


$AppId= $Sp | select -expandproperty appId
$SpObjId=az ad sp show --id $AppId --query objectId -o tsv
az ad app owner add --id $AppId --owner-object-id $SpObjId
az ad app permission add --id $AppId --api $MsGraphApi --api-permissions "$MsGraphApiRoleId=Role"
az ad app permission grant --id $AppId --api $MsGraphApi
az ad app permission add --id $AppId --api $AadGraphApi --api-permissions "$AadGraphApiRoleId=Role"
az ad app permission grant --id $AppId --api $AadGraphApi
az ad app permission list --id $AppId
```

3. Create a Service Connection in Azure DevOps (as per this [post](https://gordon.byers.me/azure/create-empty-azure-azuredevops-serviceconnections.html) as a `Azure Resource Manager` `Service Principal (Manual)`
4. Create a Pipeline in Azure DevOps, adding a Azure CLI task

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
