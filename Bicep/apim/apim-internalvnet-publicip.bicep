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

@description('Fqdn of the API Gateway custom hostname')
param gatewayCustomHostname string = 'apimgw.private.azdemo.co.uk'

@description('The base64 encoded SSL certificate for the APIM gateway')
param gwSslCert string = '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'


@description('Fqdn of the Developer Portal custom hostname')
param devPortalCustomHostname string = 'apimdevportal.private.azdemo.co.uk'

@description('The base64 encoded SSL certificate for the APIM developer portal')
param devPortalSslCert string = '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'


@description('Fqdn of the Management endpoint')
param managementCustomHostname string = 'apimmgmt.private.azdemo.co.uk'

@description('The base64 encoded SSL certificate for the management endpoint')
param managementSslCert string = 'MIILcQIBAzCCCzcGCSqGSIb3DQEHAaCCCygEggskMIILIDCCBdcGCSqGSIb3DQEHBqCCBcgwggXEAgEAMIIFvQYJKoZIhvcNAQcBMBwGCiqGSIb3DQEMAQYwDgQIey/K5P0ejpcCAggAgIIFkKIQJYlVXsR6jxMyXQElTtog3drK9cGMDfQkY9TGb9RR+1YqkkxY/bAHqsRazmvhAS7ciznDyVRfKg+VJ52FhomPwUE5Oxi6If4qHZzkUOwclBpdPtYKNR9UkkoXcxhTljyzYaiiZ+GckURhsxiukZK/ZdtR80PQGZUZZhm8YU+36mRoyUplkCWDfxo8Q8iFp4z318MtaHFumMSz4mfroCcipSq30RjnutBqTyqfc2M9xcl0D70Oqri7fGPxwBsCbfWVEo6/RiVdhAEYbGhFUDrdmSe9AvkM2upbCvDxSosMdyhpWbB8N0UUAlow6E3FXT/cjjjxUNLZpi+knda3X0INUTTff6rJO1ANOOK/DgWGJBiChTEWNLH/FdOuUr0ghte2uivLEeEc+IGccxBSToSFdBBc076uNMOL3oKwRuUdlqzbN3YPaH+TXI4QoSUeFYIocc63jIuBmF8bU2JM3lks44csG9InRl+RH3v4Sz0yzFEUlRmfeqgbai8du1CtyoFh+0X38bjpCZgeIO7VMUk+ikYZeNALqN5u2UG5qnjxONPN0MCmDnbG7gZeiw7nF1OW88XUffV4OTOmoC4h2f+IMB/LERRNHMFMwO/eCXTejQBTUg1blfUS43C4JifhEiAvRA01wgtgKUC+JlUVVNSSXXaZuVYRaho8KrSFft3GlW832iwyh8wBXrUDkqjEg2TY1E1f67b91NMIo/SpE0y5/vxhpNnrrSgKd0bYLNHd1mOdqIs5tPqmPK+Qda3c51DSNHOSLg+WFT6kaBGR7YGAWOg8KtSHVxezHrWW8cRI0Uox7adhAQEbUAnxu8MIz0HsVVj3qzE6u51+GDd8Nl3xFyanlqxCPcqDMrCz8dy7HaIwFOJwClD78N+fUDkBqJQaPxnYdnFI6J0TByYeZ2Xwahu8Oi/CJzwGnIJr3ZmT+JmcSLcU1lYX0NHMb8l1NojNN2uGtHO4EGdZb7HKHeO58MMTBbTeuLJZFl1xHdH8NhdC+o/QnSQ67o4QpQf5C0hM0khl7aU0dDF9ENyqu5OdzWwHG0JBaThdqQmTmDbtR12cgzA0t9lozPHIEb2wFPW/zrIbmkxVWlt7F9034EHpdKBIZqjPm+Rhdc4JQAx20DTabQP4WZJFne8xZEcPCcS/PoToIzBSA3iivz1Je+o7y36xgQBXFWaRnUqHMh9cqjTBHSkWYmc3tmOE3cnlAQYygeLjWQGn3skXo/1zoc6dg4XhKbzxW6a5XPPzY6EfKafUi7OLe9A6aDy8XSEWq+BEaxoTIqN2lK+rUHXStYlwWtUalFymyz89nB6+aI5crQ8AC4ms/K0UogQRACOCqah1wyVQPmCr/g5vFZkWn4hHrea1DtPsPIzgfc2q5mq3g4D9FM3hcVfCMZgBZaXMZZbsNvmBbSjszuuHKnmKnnnGR/T/q6MUYDtxF/xU2QHz3Jjghn/06REHlD1NApY8rGyDWzeody9synFixdqtL4SEM6GatyJXMqYmHwvSlQR0KK71CddE2wFNP4VmlMTux5rkduGWv7de4UXTnEIaayBD8f7p2J86QMLgRutZveG3vHhWo3EfXYiCw6j0RJn39SaPYasE5o3pORD+7kkqAbG7Dls/S1DGOQQ+4wx/n6ZeZZ7UpddHJ5QROmIwOUrf+Vm+DmLwFv484W/LDcxuep5FfwwLB/yCkBnNfSJBaE4kyevDpWcp3VV55hnTao9XHB0rHjF9xSQMWgieax91tTIgca/RIoEQWb/RzQN8q93+4jBh2S8FnIoIOSIaCAouaaz572KCUInj+mT83BY9efgkvPATFYySmCjrPuZqUF8bfl4knGi57Th/P5QymrUCKM3fXHZleQ2Tl0KeihtytUYjww+bvYKclVx8a6GkjXTAMIIFQQYJKoZIhvcNAQcBoIIFMgSCBS4wggUqMIIFJgYLKoZIhvcNAQwKAQKgggTuMIIE6jAcBgoqhkiG9w0BDAEDMA4ECEpjiNPquIiOAgIIAASCBMhfQZTAz4H1hLmUN8HNgtVxB+CHZIFXdtst9dB5zL8oU+iJRJn9aZf4BejWdqsqH4AbUuL1ycdaPbIAs4ANTQyA7jYcxw4s0cpBreCTp22ZPj4yIVWEN9quZ4oo+FyUNiE3lu06SqEH15snIjEUumSWWa+QRakD7X6xtSrwxlt19CFcs6ZfUI5Nero8TOd+/zMu8ETF4RI7z/Z3eJoqVIxI0sF1tmiwBUSLtpxbTpBAIsM9/PH5MESwfRi8TI3r+DGWLwRrQaXL6W17g4zCSQOQO+b7y7JjfLROorPztR/dxtrNIt9GVOUXu/tpI82wZsiKMsTf0kU3oOe8LSqmAb1VWQ20cC8VK3rdY/bGikZFztADK/SdBWGcdXsang4DaOO9wzn/WH9m6y85RfTGQzyUEI1oTKcRjKVtTKdQ9outHsyhBwVsb0v/t+VRo3k3aa8L3BNtRiQw+DKz9O7oPm6EvKQjbGkRRoyxWXbaEtLhy9xWWZJ+Dt+9sJHTg+TM1CiD1wFCuRl8Oo/Tw7O2yqgM+gGWTGvaa0zjOyuly5uZ1315ZPSdTGLd8ttQyOM3Q5SAnfLkW/fsagVgLFQa0u6LYHhsO2WseIL/XrIljMqsjGwf3KokhqCxUZhZ592JwBvvpmkfRDzUtKQ0ziQrf/y3MZsq0vTCadvZiK4g0qgMUi33GKgsBRS6vM2ZDoBa5VjrfzYifSd1kYIZ7D+yumYcuX9Xw84aw0O/PJ2Hk6Pd3AALkFT5/5UxbakABvrnBHBQRh+wdwmeuaQe/d2VzB0EN9AoewrmeRs4DOoFHrNUUiVl2HyHhSvf3pf1suT4BOK44LXt/llPHsQImwd8GlborbrWDRmF5DBivca8tlz+Ocz1Et/QZz2bIwMB9DshPgF1FZh2JRrjflYzgXZFnSvQzFJ6PgjmrHEG32Ng4fCmkV8dG4h6GCLa2MwOQ3nhjFwkvT0W1SISgI1fSiPXNomO8Z9S0yXJ+b9H6bKqPHutD2h3n5qN/HiIPsnlFE2UMC2rim19FvhaMwpXRyxIU1wXk4mQtyogSCZwXU7gPwTtz7rTpuyzn6OeKcY1kDjpE6HercIhJOpz8QC/DUNOdyJ63cSYa/TlifucH7zEj8cnhdTlniA3PC+I1Rvz5rtvDakJZnZBH+Y7HHfmC9fS+qN+AIMdw8m6v42Uf1+cr4mjFZprJp85xUWZMTcbD+Ad6E4+5Ix5aaGYL4zKKElASUyGN1i96GpjKaQ8lxsVgC5+YUc3Kattu8/r5laDRfsx8NunTqGxzcbYNzk7PjK5hCX7v60vN+0UBodzI8xQNS54nDE4HfKBhmHkoBhxCvcBFcDJknO2g4uPpVy/t4aFHereqTYIInvp5v3RLdVe5efhry/lNoe/cyCE9+Yd/s5rOE/n/g9qwfNBFId1rySQrhw9iFLhlEyspWBsOVSqaH0MbZYs6lukn3YLkFWov0JEhSeMXIM6i3mILLnj/LhlAk77UM3OsPe8Dv7mKjCLMEIQ5RimmlFz9rmrK2Yk4sfpw2gDDHtqZv0aPl6SnKR2xRrlMDpozeOadYMKi9kbxvX1msxJ/WE4jdDWfeNYwxSIeLEmuIProCp6yQ33MPpoXJeDaQl2Kw7e0NkxJTAjBgkqhkiG9w0BCRUxFgQU0IPl6A2ijJ+YfhxNdbIhH9rFVQQwMTAhMAkGBSsOAwIaBQAEFM/vrc14JcD6eRJESthoJRJQiJyBBAh0idTYCPFGqwICCAA='


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

resource kvDpSSLSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
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

resource kvMgmtSSLSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
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
        identityClientId: apiUai.properties.clientId
        defaultSslBinding: true
      }
      {
        type: 'DeveloperPortal'
        hostName: devPortalCustomHostname
        keyVaultId: kvDpSSLSecret.properties.secretUri //'${keyVault.properties.vaultUri}secrets/gwsslcert'
        identityClientId: apiUai.properties.clientId
      }
      {
        type: 'Management'
        hostName: managementCustomHostname
        keyVaultId: kvMgmtSSLSecret.properties.secretUri //'${keyVault.properties.vaultUri}secrets/gwsslcert'
        identityClientId: apiUai.properties.clientId
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
