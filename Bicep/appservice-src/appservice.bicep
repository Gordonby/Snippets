@description('The name seed for your application. Check outputs for the actual name and url')
param appName string
param webAppName string = 'app-${appName}-${uniqueString(resourceGroup().id, appName, deployment().name)}'

param location string =resourceGroup().location

@description('ResourceId of the web app host plan')
param hostingPlanId string

param doSourceDeploy bool = true

param createStagingSlot bool = false

  //scmType: 'ExternalGit'
  //scmType: 'GitHub'
  //scmMinTlsVersion: '1.2'
var siteConfig = {
  phpVersion: 'OFF'
  netFrameworkVersion: 'v6.0'
  alwaysOn: true
  metadata: [
    {
      name: 'CURRENT_STACK'
      value: 'dotnet'
    }
  ]
}

resource webapp 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  location: location
  kind: 'app'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: hostingPlanId
    clientAffinityEnabled: true
    siteConfig: siteConfig
  }

  resource webAppConfig 'config' = {
    name: 'web'
    properties: {
      scmType: 'ExternalGit'
    }
  }
}

output appUrl string = webapp.properties.defaultHostName
output appName string = webapp.name
output id string = webapp.id

var deploymentSlotName = 'staging'
resource slot 'Microsoft.Web/sites/slots@2022-09-01' = if(createStagingSlot) {
  name: deploymentSlotName
  location: location
  properties:{
    siteConfig: siteConfig
    enabled: true
    serverFarmId: hostingPlanId
  }
  parent: webapp
}

resource webAppLogging 'Microsoft.Web/sites/config@2022-09-01' = {
  parent: webapp
  name: 'logs'
  properties: {
    applicationLogs: {
      fileSystem: {
        level: 'Warning'
      }
    }
    httpLogs: {
      fileSystem: {
        enabled: true
        retentionInDays: 1
        retentionInMb: 25
      }
    }
  }
}


// resource webAppConfig 'Microsoft.Web/sites/config@2022-09-01' = {
//   parent: webapp
//   name: 'web'
//   properties: {
//     scmType: 'ExternalGit'
//   }
// }

// resource Microsoft_Web_sites_config_appname_web 'Microsoft.Web/sites/config@2022-09-01' = {
//   parent: webapp
//   name: 'web'
//   properties: {
//     scmType: 'ExternalGit'
//     scmMinTlsVersion: '1.2'
//   }
// }

param repoUrl string = ''
param repoBranchProduction string = 'main'
resource codeDeploy 'Microsoft.Web/sites/sourcecontrols@2022-09-01' = if (doSourceDeploy && !empty(repoUrl)) {
  parent: webapp
  name: 'web'
  properties: {
    repoUrl: repoUrl
    branch: repoBranchProduction
    isManualIntegration: true
  }
}

// param repoBranchStaging string = ''
// resource slotCodeDeploy 'Microsoft.Web/sites/slots/sourcecontrols@2022-09-01' = if (!empty(repoUrl) && !empty(repoBranchStaging)) {
//   parent: slot
//   name: 'web'
//   properties: {
//     repoUrl: repoUrl
//     branch: repoBranchStaging
//     isManualIntegration: true
//   }
// }

resource sites_colourz_name_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  name: 'ftp'
  parent: webapp
  properties: {
    allow: true
  }
}

resource sites_colourz_name_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-09-01' = {
  name: 'scm'
  parent: webapp
  properties: {
    allow: true
  }
}
