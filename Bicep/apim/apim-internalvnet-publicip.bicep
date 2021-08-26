@description('Used in the naming of Az resources')
@minLength(3)
param nameSeed string = 'myproject'

@description('The email address of the owner of the service')
@minLength(1)
param publisherEmail string = 'gobyers@microsoft.com'

@description('The name of the owner of the service')
@minLength(1)
param publisherName string = 'Gobyers'

@description('The pricing tier of this API Management service')
@allowed([
  'Developer'
  'Premium'
])
param sku string = 'Developer'

@description('The instance size of this API Management service.This should be in multiple of zones getting deployed.')
param skuCount int = 1

@description('Existing Virtual Network Resource Group name')
param virtualNetworkRGName string = 'Automation-Actions-AksDeployVnet'

@description('Existing Virtual Network name')
param virtualNetworkName string = 'aksdeployvnet1'

@description('Subnet Name')
param subnetName string = 'apim'

@description('Subnet Address range')
param subnetCidr string = '172.21.2.0/26'

@description('Azure region where the resources will be deployed')
param location string = resourceGroup().location

@description('Zone numbers e.g. 1,2,3.')
param availabilityZones array = [
  '1'
  '2'
  '3'
]

@description('Deploy a PublicIp')
param publicIp bool = true

var publicIpName = 'pip-${nameSeed}'
var publicIPAllocationMethod  = 'Static'
var publicIpSku = 'Standard'
var dnsLabelPrefix = toLower('${nameSeed}-${uniqueString(nameSeed, resourceGroup().id)}')

var apiManagementServiceName_var = 'apim-${nameSeed}'

module apimNetworking 'apim-networking.bicep' = {
  name: 'ApimNetworking'
  scope: resourceGroup(virtualNetworkRGName)
  params: { 
    nameSeed:nameSeed
    subnetName: subnetName
    subnetCidr: subnetCidr
    virtualNetworkName: virtualNetworkName
  }
}

resource apimPip 'Microsoft.Network/publicIPAddresses@2021-02-01' = if(publicIp) {
  name: publicIpName
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

resource apiManagementServiceName 'Microsoft.ApiManagement/service@2021-01-01-preview' = {
  name: apiManagementServiceName_var
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }
  zones: ((length(availabilityZones) == 0 || sku=='Developer') ? json('null') : availabilityZones)
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkType: 'Internal'
    publicIpAddressId: (publicIp ? apimPip.id : json('null'))
    virtualNetworkConfiguration: {
      subnetResourceId: apimNetworking.outputs.subnetId
    }
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'false'
    }
  }
}
