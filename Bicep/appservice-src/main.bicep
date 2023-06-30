@description('The name seed for all your other resources.')
param resNameSeed string = 'color'

@description('The short application name of the Function App')
param appName string = 'colorapp'

param apiName string = 'colorapi'

param hostingPlanName string = 'plan-${resNameSeed}'

param location string = resourceGroup().location

var AppGitRepoUrl = 'https://github.com/Gordonby/ColorsWeb.git'
var ApiGitRepoUrl = 'https://github.com/Gordonby/ColorsAPI.git'

module app 'appservice.bicep' = {
  name: 'appservice-${appName}-${resNameSeed}'
  params: {
    hostingPlanId: hostingPlan.id
    appName: appName
    location: location
    repoUrl: AppGitRepoUrl
    repoBranchProduction: 'main'
  }
}

// module api 'appservice.bicep' = if(!empty(ApiGitRepoUrl)) {
//   name: 'appservice-${apiName}-${resNameSeed}'
//   params: {
//     hostingPlanId: hostingPlan.id
//     appName: apiName
//     location: location
//     repoUrl: ApiGitRepoUrl
//     repoBranchProduction: 'main'
//   }
// }

resource hostingPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: hostingPlanName
  location: location
  sku: {
    tier: 'Standard'
    name: 'S1'
  }
  properties: {
    zoneRedundant: false
  }
}
