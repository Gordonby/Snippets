param automationAccountName string
param location string = resourceGroup().location
param today string = utcNow('yyyyMMddTHHmmssZ')

@description('The timezone to align schedules to. (Eg. "Europe/London" or "America/Los_Angeles")')
param timezone string = 'Etc/UTC'

var tomorrow = dateTimeAdd(today, 'P1D','yyyy-MM-dd')
var automationStartTimeMidnight = '${take(tomorrow,10)}T00:01:00+00:00'
var automationStartTime9am = '${take(tomorrow,10)}T09:00:00+00:00'

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

resource automationScheduleNight 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = {
  parent: automationAccount
  name: 'Midnight'
  properties: {
    startTime: automationStartTimeMidnight
    expiryTime: '9999-12-31T23:59:00+00:00'
    interval: 1
    frequency: 'Day'
    timeZone: timezone
    description: 'Daily out of hours schedule'
  }
}

resource automationScheduleMorn 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = {
  parent: automationAccount
  name: '9am'
  properties: {
    startTime: automationStartTime9am
    expiryTime: '9999-12-31T23:59:00+00:00'
    interval: 1
    frequency: 'Day'
    timeZone: timezone
    description: 'Daily out of hours schedule'
  }
}

var runbookNames = [runbookCleanRG.name, runbookDeleteRGs.name]
resource automationJobNightSchedules 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = [for runbookName in runbookNames : {
  parent: automationAccount
  name: guid(automationAccount.id, runbookName, automationScheduleNight.name)
  properties: {
    schedule: {
      name: automationScheduleNight.name
    }
    runbook: {
      name: runbookName
    }
  }
}]

resource automationJobMornSchedule 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = {
  parent: automationAccount
  name: guid(automationAccount.id, runbookUntaggedRGs.name, automationScheduleNight.name)
  properties: {
    schedule: {
      name: automationScheduleMorn.name
    }
    runbook: {
      name: runbookUntaggedRGs.name
    }
  }
}

output automationAccountPrincipalId string = automationAccount.identity.principalId
