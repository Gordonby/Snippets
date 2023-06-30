param appplanName string = 'egv-appplan'
param location string = resourceGroup().location
param appname string = 'egv-${uniqueString(resourceGroup().id, deployment().name)})})}'

resource plan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appplanName
  location: location
  sku: {
    name: 'S1'
    capacity: 1
  }
  tags: {
    displayName: appplanName
  }
}

resource webapp 'Microsoft.Web/sites@2022-09-01' = {
  name: appname
  location: location
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      webSocketsEnabled: true
      netFrameworkVersion: 'v6.0'
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
    }
    httpsOnly: true
  }
}

resource appname_web 'Microsoft.Web/sites/sourcecontrols@2022-09-01' = {
  parent: webapp
  name: 'web'
  properties: {
    repoUrl: 'https://github.com/Gordonby/ColoursWeb.git'
    branch: 'main'
    isManualIntegration: true
  }
}

resource Microsoft_Web_sites_config_appname_web 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: webapp
  name: 'web'
  properties: {
    scmType: 'ExternalGit'
    scmMinTlsVersion: '1.2'
  }
}
