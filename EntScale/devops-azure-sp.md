## Equipping Azure DevOps with a Service Principal

1. Create a Service Principal with no RBAC
```bash
Sp=$(az ad sp create-for-rbac -n "spbootstrap" --skip-assignment -o json)
```

2. [Option 1] Make the SP an owner of it's App counterpart (otherwise it won't be able to read the Application ObjectId later)

```bash
AppId=$(echo $Sp | jq -r '.appId')
SpObjId=$(az ad sp show --id $AppId --query objectId -o tsv)
az ad app owner add --id $AppId --owner-object-id $SpObjId
#need to add permission too
```

2. [Option2] Give the SP permission to Sign in and read user profile

```bash
az ad app permission add --id $AppId --api 00000003-0000-0000-c000-000000000000 --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope
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
