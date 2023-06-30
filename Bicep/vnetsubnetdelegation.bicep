param location string = resourceGroup().location
param vNetName string = 'vnetGord'
param vNetAddressPrefix string = '10.0.0.0/16'

resource vnet 'Microsoft.Network/virtualNetworks@2022-11-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [vNetAddressPrefix]
    }
  }
}

resource serverFarmSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: 'aSubnet'
  parent: vnet
  properties: { 
    addressPrefix: '10.0.1.0/24'
    delegations: [
      {
        name: 'Microsoft.Web/serverfarms'
        properties: {
          serviceName: 'Microsoft.Web/serverfarms'
        }
      }
    ]
  }
}

resource serverFarmSubnet2 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: 'aSubnet2'
  parent: vnet
  properties: { 
    addressPrefix: '10.0.2.0/24'
    delegations: [
      {
        name: 'Microsoft.Web/serverfarms'
        properties: {
          serviceName: 'Microsoft.Web/serverfarms'
        }
      }
    ]
  }
}

resource serverFarmSubnet3 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: 'aSubnet3'
  parent: vnet
  properties: { 
    addressPrefix: '10.0.3.0/24'
    delegations: [
      {
        name: 'Microsoft.Web/serverfarms'
        properties: {
          serviceName: 'Microsoft.Web/serverfarms'
        }
      }
    ]
  }
}
