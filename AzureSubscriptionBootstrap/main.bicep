targetScope='subscription'

param automationAccountName string = 'subscriptionMaintain'
param location string = deployment().location

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'automation'
  location: location
  tags: {
    Cleanup:'Never'
  }
}

module automation 'automation.bicep' = {
  scope: resourceGroup(rg.name)
  name: '${deployment().name}-automation'
  params: {
    automationAccountName: automationAccountName
    location: location
  }
}

var contributorRole = resourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, automationAccountName, contributorRole)
  properties: {
    roleDefinitionId: contributorRole
    principalId: automation.outputs.automationAccountPrincipalId
    principalType: 'ServicePrincipal'
  }
}
