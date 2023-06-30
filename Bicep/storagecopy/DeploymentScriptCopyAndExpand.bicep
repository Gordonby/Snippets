param storageAccountName string



@description('The location of the ACR and where to deploy the module resources to')
param location string = resourceGroup().location

@description('How the deployment script should be forced to execute')
param forceUpdateTag  string = utcNow()

@description('Azure RoleId that are required for the DeploymentScript resource to import images')
param rbacRoleNeeded string = 'b24988ac-6180-42a0-ab88-20f7382dd24c' //Contributor is needed to build ACR tasks

@description('Does the Managed Identity already exists, or should be created')
param useExistingManagedIdentity bool = false

@description('Name of the Managed Identity resource')
param managedIdentityName string = 'id-ContainerRegistryBuild'

@description('For an existing Managed Identity, the Subscription Id it is located in')
param existingManagedIdentitySubId string = subscription().subscriptionId

@description('For an existing Managed Identity, the Resource Group it is located in')
param existingManagedIdentityResourceGroupName string = resourceGroup().name

@description('A delay before the script import operation starts. Primarily to allow Azure AAD Role Assignments to propagate')
param initialScriptDelay string = '30s'

@allowed([
  'OnSuccess'
  'OnExpiration'
  'Always'
])
@description('When the script resource is cleaned up')
param cleanupPreference string = 'OnSuccess'

resource newDepScriptId 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = if (!useExistingManagedIdentity) {
  name: managedIdentityName
  location: location
}

resource existingDepScriptId 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = if (useExistingManagedIdentity ) {
  name: managedIdentityName
  scope: resourceGroup(existingManagedIdentitySubId, existingManagedIdentityResourceGroupName)
}

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(rbacRoleNeeded)) {
  name: guid(resourceGroup().id, rbacRoleNeeded, useExistingManagedIdentity ? existingDepScriptId.id : newDepScriptId.id)
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', rbacRoleNeeded)
    principalId: useExistingManagedIdentity ? existingDepScriptId.properties.principalId : newDepScriptId.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource createImportImage 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'Check-Prereqs'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${useExistingManagedIdentity ? existingDepScriptId.id : newDepScriptId.id}': {}
    }
  }
  kind: 'AzureCLI'
  dependsOn: [
    rbac
  ]
  properties: {
    forceUpdateTag: forceUpdateTag
    azCliVersion: '2.30.0'
    timeout: 'PT45M'
    retentionInterval: 'P1D'
    environmentVariables: [
      {
        name: 'initialDelay'
        value: initialScriptDelay
      }
      {
        name: 'storAcc'
        value: storageAccountName
      }
      {
        name: 'shareName'
        value: ''
      }
      {
        name: 'accessKey'
        secureValue: ''
      }
    ]
    scriptContent: '''
    sleep $initialDelay

    az --version
    '''
    cleanupPreference: cleanupPreference
  }
}
