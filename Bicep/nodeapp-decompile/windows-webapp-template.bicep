param webAppName string
param hostingPlanName string
param appInsightsLocation string
param databaseAccountId string
param databaseAccountLocation string

resource webAppName_resource 'Microsoft.Web/sites@2016-08-01' = {
  name: webAppName
  location: resourceGroup().location
  tags: {
    'hidden-related:/subscriptions/${subscription().subscriptionId}/resourcegroups/${resourceGroup().name}/providers/Microsoft.Web/serverfarms/${hostingPlanName}': 'empty'
  }
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: reference(Microsoft_Insights_components_webAppName.id, '2015-05-01').InstrumentationKey
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '14.15.1'
        }
      ]
      phpVersion: '7.1'
    }
    name: webAppName
    serverFarmId: '/subscriptions/${subscription().subscriptionId}/resourcegroups/${resourceGroup().name}/providers/Microsoft.Web/serverfarms/${hostingPlanName}'
    hostingEnvironment: ''
  }
  dependsOn: [
    hostingPlanName_resource
  ]
}

resource webAppName_Microsoft_ApplicationInsights_AzureWebSites 'Microsoft.Web/sites/siteextensions@2015-08-01' = {
  parent: webAppName_resource
  name: 'Microsoft.ApplicationInsights.AzureWebSites'
  properties: {}
}

resource hostingPlanName_resource 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: hostingPlanName
  location: resourceGroup().location
  sku: {
    name: 'P2v3'
    tier: 'PremiumV3'
    size: 'P2v3'
    family: 'Pv3'
    capacity: 1
  }
  kind: 'app'
  properties: {
    perSiteScaling: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

resource databaseAccountId_sampledatabase 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2020-06-01-preview' = {
  parent: databaseAccountId_resource
  name: 'sampledatabase'
  properties: {
    resource: {
      id: 'sampledatabase'
    }
    options: {}
  }
}

resource databaseAccountId_sampledatabase_samplecollection 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections@2020-06-01-preview' = {
  parent: databaseAccountId_sampledatabase
  name: 'samplecollection'
  properties: {
    resource: {
      id: 'samplecollection'
      indexes: []
    }
    options: {}
  }
  dependsOn: [
    databaseAccountId_resource
  ]
}

resource databaseAccountId_sampledatabase_samplecollection_default 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections/throughputSettings@2020-06-01-preview' = {
  parent: databaseAccountId_sampledatabase_samplecollection
  name: 'default'
  properties: {
    resource: {
      throughput: 400
    }
  }
  dependsOn: [
    databaseAccountId_sampledatabase
    databaseAccountId_resource
  ]
}

resource Microsoft_Insights_components_webAppName 'Microsoft.Insights/components@2014-04-01' = {
  name: webAppName
  location: appInsightsLocation
  tags: {
    'hidden-link:${resourceGroup().id}/providers/Microsoft.Web/sites/${webAppName}': 'Resource'
  }
  properties: {
    applicationId: webAppName
    Request_Source: 'AzureTfsExtensionAzureProject'
  }
}

resource databaseAccountId_resource 'Microsoft.DocumentDb/databaseAccounts@2015-04-08' = {
  kind: 'MongoDB'
  name: databaseAccountId
  location: databaseAccountLocation
  properties: {
    databaseAccountOfferType: 'Standard'
    name: databaseAccountId
  }
}

output azureCosmosDBAccountKeys object = listConnectionStrings('Microsoft.DocumentDb/databaseAccounts/${databaseAccountId}', '2015-04-08')