

@description('The location to deploy the resources to')
param location string = resourceGroup().location

resource dsInfo 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'WinGetInfo3'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    retentionInterval: 'PT1H'
    azPowerShellVersion: '9.7'
    cleanupPreference: 'OnSuccess'
    environmentVariables: [
      {
        name: 'waitSeconds'
        value: '5'
      }
    ]
    scriptContent: loadTextContent('getInfo.ps1')
  }
}

output out object = dsInfo.properties.outputs
