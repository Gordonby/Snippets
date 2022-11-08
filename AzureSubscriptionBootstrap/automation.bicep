param location string = resourceGroup().location

resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: 'subscriptionMaintain'
  location: location
  properties: {
    sku: {
      name: 'Free'
    }
  }
}

resource automationRunbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  parent: automationAccount
  name: 'CleanRgResources'
  location: location
  properties: {
    logVerbose: true
    logProgress: true
    runbookType: 'Script'
    publishContentLink: {
      uri: 'https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureSubscriptionBootstrap/cleanRgResources.ps1'
      version: '1.0.0.0'
    }
    description: 'Deletes the resources in tagged resource groups'
  }
}
