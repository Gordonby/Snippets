@minLength(1)
param vmName string

@secure()
param vmAdminPassword string

@allowed([
  '2008-R2-SP1'
  '2012-Datacenter'
  '2012-R2-Datacenter'
  '2016-Datacenter'
])
param vmWindowsOSVersion string = '2016-Datacenter'

@allowed([
  'Small'
  'Medium'
  'Large'
])
param VmSize string = 'Small'

var VmShirtSize = {
  Small: 'Standard_A0'
  Medium: 'Standard_A3'
  Large: 'Standard_D2_V2'
}
var vmAdminUserName = 'adminsnow'
var vmVmSize = VmShirtSize[VmSize]
var vmNicName_var = '${vmName}NetworkInterface'
var virtualNetworkName = 'SnowLabVNet'
var virtualNetworkResourceGroup = 'SnowLab'
var vmVnetID = resourceId(virtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks', virtualNetworkName)
var vmSubnetRef = '${vmVnetID}/subnets/Windows-Sandbox'
var nestedTemplateRoot = 'https://raw.githubusercontent.com/Gordonby/ArmLab2/master/scripts/Ex2/nested/'

resource vmNicName 'Microsoft.Network/networkInterfaces@2016-03-30' = {
  name: vmNicName_var
  location: 'westeurope'
  tags: {
    displayName: 'vmNic'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vmSubnetRef
          }
        }
      }
    ]
  }
  dependsOn: []
}

resource vmName_resource 'Microsoft.Compute/virtualMachines@2016-04-30-preview' = {
  name: vmName
  location: resourceGroup().location
  tags: {
    displayName: 'vm'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmVmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmAdminUserName
      adminPassword: vmAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: vmWindowsOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNicName.id
        }
      ]
    }
  }
}

module Shutdown_policy '?' /*TODO: replace with correct path to [concat(variables('nestedTemplateRoot') ,'Shutdown.json')]*/ = {
  name: 'Shutdown-policy'
  params: {
    virtualMachineName: vmName
  }
  dependsOn: [
    vmName_resource
  ]
}