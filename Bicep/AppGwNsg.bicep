param appGwName string = 'agw-Byo'
param appGwRG string = 'Automation-Actions-AksDeployCI'
param appGwSubnetCidr string = '172.21.1.0/27'

resource appGw 'Microsoft.Network/applicationGateways@2021-03-01' existing =  {
  name: appGwName
  scope: resourceGroup(appGwRG)
}

resource appGwNsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: 'nsg-${appGwName}'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'Allow_GWM'
        properties: {
          priority: 100
          protocol: '*'
          access: 'Allow'
          direction: 'Inbound'
          description: 'Azure infrastructure communication'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: 'GatewayManager'
          destinationAddressPrefix: appGwSubnetCidr
          sourcePortRange: '*'
        }
      }
      {
        name: 'Allow_AzureLoadBalancer'
        properties: {
          priority: 110
          protocol: '*'
          access: 'Allow'
          direction: 'Inbound'
          description: ''
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: appGwSubnetCidr
          sourcePortRange: '*'
        }
      }
      {
        name: 'Deny_AllInboundInternet'
        properties: {
          priority: 4096
          protocol: '*'
          access: 'Deny'
          direction: 'Inbound'
          description: 'Azure infrastructure communication'
          destinationPortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: appGwSubnetCidr
          sourcePortRange: '*'
        }
      }
    ]
  }
}
