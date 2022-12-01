//Test file to see if VirtualNodes works via ARM.

param nameseed string = 'gbtest4'
param location string = resourceGroup().location
param virtualNodesSubnetName string = 'vnodes'
param serviceCidr string = '172.10.0.0/16'
param dnsServiceIP string = '172.10.0.10'
param dockerBridgeCidr string = '172.17.0.1/16'

var aksSubnetName = 'aks'
var aksSubnetId = '${virtualNetwork.id}/subnets/${aksSubnetName}'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: 'vnet-${nameseed}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: aksSubnetName
        properties: {
          addressPrefix: '10.0.0.0/22'
        }
      }
      {
        name: virtualNodesSubnetName
        properties: {
          addressPrefix: '10.0.6.0/24'
        }
      }
    ]
  }
}


resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-09-02-preview' = {
  name: 'aks-${nameseed}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'dnsprefix'
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 1
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: aksSubnetId
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIP
      dockerBridgeCidr: dockerBridgeCidr
    }
    addonProfiles: {
      aciConnectorLinux: {
        enabled: true
        config: {
          SubnetName: virtualNodesSubnetName
        }
      }
    }
  }
}
