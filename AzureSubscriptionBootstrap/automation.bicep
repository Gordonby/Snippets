param automationAccountName string
param location string = resourceGroup().location

resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: automationAccountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    sku: {
      name: 'Free'
    }
  }
}
output automationAccountPrincipalId string = automationAccount.identity.principalId

resource automationRunbook 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
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

resource automationSchedule 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = {
  parent: automationAccount
  name: 'Midnight'
  properties: {
    startTime: '2022-09-02T00:01:00+01:00'
    expiryTime: '9999-12-31T23:59:00+00:00'
    interval: 1
    frequency: 'Day'
    timeZone: 'Europe/London'
  }
}
