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

param existingPrivateDnsZone string = ''

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

@description('Fqdn of the API Gateway custom hostname')
param gatewayCustomHostname string = ''

@description('The base64 encoded SSL certificate for the APIM gateway')
param gwSslCert string = ''

@description('Fqdn of the Developer Portal custom hostname')
param devPortalCustomHostname string = ''

@description('The base64 encoded SSL certificate for the APIM developer portal')
param devPortalSslCert string = ''

@description('Fqdn of the Management endpoint')
param managementCustomHostname string = ''

@description('The base64 encoded SSL certificate for the management endpoint')
param managementSslCert string = ''

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

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = if (!empty(gwSslCert) || !empty(devPortalSslCert) || !empty(managementSslCert)) {
  name: keyvaultName
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: apiUai.properties.tenantId
    accessPolicies: [
      {
        tenantId: apiUai.properties.tenantId
        objectId: apiUai.properties.principalId
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

resource kvGwSSLSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = if (!empty(gwSslCert)) {
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
output kvGwSSLSecretId string = kvGwSSLSecret.id

resource kvDpSSLSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = if (!empty(devPortalSslCert)) {
  name: '${keyVault.name}/dpsslcert'
  properties: {
    value: devPortalSslCert
    contentType: 'application/x-pkcs12'
    attributes: {
      enabled: true
      nbf: 1585206000
      exp: 1679814000
    }
  }
}

resource kvMgmtSSLSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = if (!empty(managementSslCert)) {
  name: '${keyVault.name}/mgmtsslcert'
  properties: {
    value: managementSslCert
    contentType: 'application/x-pkcs12'
    attributes: {
      enabled: true
      nbf: 1585206000
      exp: 1679814000
    }
  }
}

//     //    ) )     /|    / /     //   ) ) 
//    //    / /     //|   / /     ((        
//   //    / /     // |  / /        \\      
//  //    / /     //  | / /           ) )   
// //____/ /     //   |/ /     ((___ / /    

// resource privDns 'Microsoft.Network/privateDnsZones@2020-06-01' existing = if (!empty(existingPrivateDnsZone)) {
//   name: existingPrivateDnsZone
// }



var createDefaultDns = empty(gatewayCustomHostname)

resource defaultdns 'Microsoft.Network/privateDnsZones@2020-06-01' = if (createDefaultDns) {
  name: 'azure-api.net'
  location: 'global'
}

resource defaultdnsvnet 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (createDefaultDns) {
  parent: defaultdns
  name: 'privatedns'
  tags: {}
  location: 'global'
  properties: {
    virtualNetwork: {
      id: apimNetworking.outputs.vnetId
    }
    registrationEnabled: false
  }
}

resource defaultdnsGwRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = if (createDefaultDns) {
  name: 'ApimGateway'
  parent: defaultdns
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: apim.properties.privateIPAddresses[0]
      }
    ]
  }
}

resource defaultdnsDevRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = if (createDefaultDns) {
  name: '${apim.name}.developer'
  parent: defaultdns
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: apim.properties.privateIPAddresses[0]
      }
    ]
  }
}

resource defaultdnsManRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = if (createDefaultDns) {
  name: '${apim.name}.management'
  parent: defaultdns
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: apim.properties.privateIPAddresses[0]
      }
    ]
  }
}



//                            ___   ___                 
//     // | |     //   ) )       / /        /|    //| | 
//    //__| |    //___/ /       / /        //|   // | | 
//   / ___  |   / ____ /       / /        // |  //  | | 
//  //    | |  //             / /        //  | //   | | 
// //     | | //           __/ /___     //   |//    | | 

var gwHostnameConfig = empty(gatewayCustomHostname) ? json('null') :{
  type: 'Proxy'
  hostName: gatewayCustomHostname
  keyVaultId: kvGwSSLSecret.properties.secretUri //'${keyVault.properties.vaultUri}secrets/gwsslcert'
  identityClientId: apiUai.properties.clientId
  defaultSslBinding: true
}
var dpHostnameConfig = empty(devPortalCustomHostname) ? json('null') :{
  type: 'DeveloperPortal'
  hostName: devPortalCustomHostname
  keyVaultId: kvDpSSLSecret.properties.secretUri //'${keyVault.properties.vaultUri}secrets/gwsslcert'
  identityClientId: apiUai.properties.clientId
}
var manHostnameConfig = empty(managementCustomHostname) ? json('null') :{
  type: 'Management'
  hostName: managementCustomHostname
  keyVaultId: kvMgmtSSLSecret.properties.secretUri //'${keyVault.properties.vaultUri}secrets/gwsslcert'
  identityClientId: apiUai.properties.clientId
}

var apimHostnameConfig = [
  gwHostnameConfig
  dpHostnameConfig
  manHostnameConfig
]


resource apim 'Microsoft.ApiManagement/service@2021-01-01-preview' = {
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
    hostnameConfigurations: apimHostnameConfig
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
output ApimName string = apim.name

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
