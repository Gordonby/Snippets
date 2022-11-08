param automationAccountName string
param location string = resourceGroup().location
param today string = utcNow('yyyyMMddTHHmmssZ')

var tomorrow = dateTimeAdd(today, 'P1D','yyyy-MM-dd')
var automationStartTime = '${take(tomorrow,10)}T00:01:00+01:00'

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

resource runbookCleanRG 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
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

resource runbookUntaggedRGs 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  parent: automationAccount
  name: 'TagResourceGroupsForDeletion'
  location: location
  properties: {
    logVerbose: true
    logProgress: true
    runbookType: 'Script'
    publishContentLink: {
      uri: 'https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureSubscriptionBootstrap/tagResourceGroups.ps1'
      version: '1.0.0.0'
    }
    description: 'Deletes the resources in tagged resource groups'
  }
}

resource runbookDeleteRGs 'Microsoft.Automation/automationAccounts/runbooks@2022-08-08' = {
  parent: automationAccount
  name: 'DeleteResourceGroups'
  location: location
  properties: {
    logVerbose: true
    logProgress: true
    runbookType: 'Script'
    publishContentLink: {
      uri: 'https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureSubscriptionBootstrap/deleteResourceGroups.ps1'
      version: '1.0.0.0'
    }
    description: 'Deletes resource groups'
  }
}

resource automationSchedule 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = {
  parent: automationAccount
  name: 'Midnight'
  properties: {
    startTime: automationStartTime //20221109T00:01:00+01:00 //"2022-09-02T00:01:00+01:00"
    expiryTime: '9999-12-31T23:59:00+00:00'
    interval: 1
    frequency: 'Day'
    timeZone: 'Europe/London'
    description: 'Daily out of hours schedule'
  }
}

var runbookNames = [runbookCleanRG.name, runbookUntaggedRGs.name, runbookDeleteRGs.name]
resource automationJobSchedules 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = [for runbookName in runbookNames : {
  parent: automationAccount
  name: guid(runbookName, automationSchedule.name)
  properties: {
    schedule: {
      name: automationSchedule.name
    }
    runbook: {
      name: runbookName
    }
  }
}]

output automationAccountPrincipalId string = automationAccount.identity.principalId
