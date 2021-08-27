@description('The email address of the owner of the service')
@minLength(1)
param publisherEmail string = 'contoso@contoso.com'

@description('The name of the owner of the service')
@minLength(1)
param publisherName string = 'Contoso'

@description('The pricing tier of this API Management service')
@allowed([
  'Basic'
  'Consumption'
  'Developer'
  'Standard'
  'Premium'
])
param sku string = 'Standard'

@description('The instance size of this API Management service.')
param skuCount int = 1

@description('An array of json objects like this : {\'name\':name, \'value\':value}')
param Secrets array

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the KeyVault to provision')
param keyVaultName string = 'kv-${uniqueString(resourceGroup().id)}'

@description('Name of the gateway custom hostname')
param gatewayCustomHostname string

var apiManagementServiceName_var = 'apim-${uniqueString(resourceGroup().id)}'
var identityName_var = 'id-${uniqueString(resourceGroup().id)}'
var identityID = identityName.id

resource identityName 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName_var
  location: location
}

resource keyVaultName_resource 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: reference(identityID).tenantId
    accessPolicies: [
      {
        tenantId: reference(identityID).tenantId
        objectId: reference(identityID).principalId
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

resource keyVaultName_Secrets_name 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = [for item in Secrets: {
  name: '${keyVaultName}/${item.name}'
  properties: {
    value: item.value
    recoveryLevel: 'Purgeable'
    contentType: 'application/x-pkcs12'
    attributes: {
      enabled: true
      nbf: 1585206000
      exp: 1679814000
    }
  }
  dependsOn: [
    keyVaultName_resource
  ]
}]

resource apiManagementServiceName 'Microsoft.ApiManagement/service@2020-06-01-preview' = {
  name: apiManagementServiceName_var
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityID}': {}
    }
  }
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: gatewayCustomHostname
        keyVaultId: '${keyVaultName_resource.properties.vaultUri}secrets/sslcert'
        identityClientId: reference(identityID).clientId
        defaultSslBinding: true
      }
    ]
    publisherEmail: publisherEmail
    publisherName: publisherName
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA': false
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA': false
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256': false
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256': false
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256': false
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': false
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': false
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': false
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': false
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': false
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': false
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': false
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': false
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': false
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': false
    }
  }
}