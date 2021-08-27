@description('Used in the naming of Az resources')
@minLength(3)
param nameSeed string

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

@description('Name of the gateway custom hostname')
param gatewayCustomHostname string = 'apimgw.azdemo.co.uk'

@description('The base64 encoded SSL certificate for the APIM gateway')
param gwSslCert string = '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'


var publicIpName = 'pip-${nameSeed}'
var publicIPAllocationMethod  = 'Static'
var publicIpSku = 'Standard'
var dnsLabelPrefix = toLower('${nameSeed}-${uniqueString(nameSeed, resourceGroup().id)}')

var keyvaultName = 'kv${nameSeed}'

var apiManagementServiceName_var = 'apim-${nameSeed}'

module apimNetworking 'apim-networking.bicep' = {
  name: '${deployment().name}-ApimNetworking' 
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

resource apiUai 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'id-${nameSeed}'
  location: location
}

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyvaultName
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: reference(apiUai.id).tenantId
    accessPolicies: [
      {
        tenantId: reference(apiUai.id).tenantId
        objectId: reference(apiUai.id).principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
    enableSoftDelete: true
  }
}

resource kvGwSSLSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/gwsslcert'
  properties: {
    value: gwSslCert
    contentType: 'application/x-pkcs12'
    attributes: {
      enabled: true
      nbf: 1585206000
      exp: 1679814000
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
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${apiUai.id}': {}
    }
  }
  properties: {
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: gatewayCustomHostname
        keyVaultId: kvGwSSLSecret.properties.secretUri //'${keyVault.properties.vaultUri}secrets/gwsslcert'
        identityClientId: reference(apiUai.id).clientId
        defaultSslBinding: true
      }
    ]
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
