targetScope='subscription'

param location string = deployment().location
param resourceName string = 'carmlTest'

//Create resource groups
resource gridRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${resourceName}-selenium'
  location: location
}

resource appRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${resourceName}-testapp'
  location: location
}

//Create vnets
module gridVnet 'br:Carml.azurecr.io/bicep/modules/microsoft.network.virtualnetworks:v0.4.0' = {
  name: 'vnet-grid-${resourceName}'
  scope: gridRg
  params: {
    name: 'vnet-grid-${resourceName}'
    location: location
    addressPrefixes: [
      '10.10.0.0/16'
    ]
    subnets: [
      {
        name: 'aks-sn'
        addressPrefix: '10.10.0.0/22'
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
    ]
  }
}

module appVnet 'br:Carml.azurecr.io/bicep/modules/microsoft.network.virtualnetworks:v0.4.0' = {
  name: 'vnet-grid-${resourceName}'
  scope: appRg
  params: {
    name: 'vnet-app-${resourceName}'
    location: location
    addressPrefixes: [
      '10.20.0.0/16'
    ]
    subnets: [
      {
        name: 'aks-sn'
        addressPrefix: '10.20.0.0/22'
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
    ]
    virtualNetworkPeerings: [
      {
        remotePeeringEnabled: true
        remoteVirtualNetworkId: gridVnet.outputs.resourceId
    }
    ]
  }
}
