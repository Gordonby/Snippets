param prefix string = 'gord'
param location string = resourceGroup().location

resource acrpub 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: '${prefix}Public'
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
    }
  }
}

resource acrprivId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${prefix}PrivateId'
  location: location
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: '${prefix}vnet'
  location: location
}

resource acrpriv 'Microsoft.ContainerRegistry/registries@2020-11-01-preview' = {
  name: '${prefix}Private'
  location: location
  sku: {
    name: 'Premium'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: acrprivId
  }
}

resource acrpull 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: PrivPullPub
  properties: {
    roleDefinitionId:  
    
  }
}