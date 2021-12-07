# Azure APIM Policies

## From Bicep

Applying a bicep policy to a specific API, via repo link 🚀

```bicep
param apimName string
param productsApiBaseUrl string = 'https://serverlessohapi.azurewebsites.net/api/'

resource apim 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: apimName
}

resource ProductApi 'Microsoft.ApiManagement/service/apis@2021-04-01-preview' = {
  name: 'ProductAPI'
  parent: apim
  properties: {
    path: 'products'
    displayName: 'Products API'
    serviceUrl: productsApiBaseUrl
    protocols: [
      'https'
    ]
    subscriptionRequired: false
  }
}

resource GetProductsCacheMethod 'Microsoft.ApiManagement/service/apis/operations@2021-04-01-preview' = {
  name: 'GetProductsCacheDemo'
  parent: ProductApi
  properties: {
    displayName: 'Get Products cache demo'
    method: 'GET'
    urlTemplate: '/GetProducts?randomqs=true'
    description: 'Get all of the Ice Cream Products. Cachey cache cache'
  }
}

resource ProductCache 'Microsoft.ApiManagement/service/apis/operations/policies@2021-04-01-preview' = {
  name: 'policy'
  parent: GetProductsCacheMethod
  properties: {
    value: 'https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureApimPolicies/CacheFor3600.xml'
    format: 'xml-link'
  }
}

```
