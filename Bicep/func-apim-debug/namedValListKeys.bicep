@description('Name of the NamedValue to deploy')
param name string

@description('Resource Id to be used in the listkeys function')
param resourceId string

@description('Used in listkeys function')
param apiVersion string = '2022-09-01'

@description('Specify if the value is secret. Defaults to false')
param secret bool = false

@description('Specify if the value is a key vault reference. Also implies value is secret. Defaults to false')
param keyVaultReference bool = false

@description('APIM environment to deploy to')
@allowed([
    'dev'
    'int'
    'act'
    'prod'
])
param environment string = 'dev'

var apimName = {
    dev: 'apim-dev-002'
    int: 'apim-int-001'
    act: 'apim-act-001'
    prod: 'apim-prod-002'
}[environment]

var value = listKeys(resourceId, apiVersion)
resource apim 'Microsoft.ApiManagement/service@2021-08-01' existing = {
    name: apimName

    resource apimNamedValue 'namedValues' = {
        name: name
        properties: {
            displayName: name
            secret: secret || keyVaultReference
            keyVault: keyVaultReference ? {
                secretIdentifier: value
            } : null
            value: !keyVaultReference ? value : null
        }
    }
}

output namedValueId string = apim::apimNamedValue.id
output namedValueName string = apim::apimNamedValue.name
output namedValueNameFormatted string = '{{${apim::apimNamedValue.name}}}'
