

@description('The location to deploy the resources to')
param location string = resourceGroup().location

resource dsAzCli 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
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
    scriptContent: loadTextContent('azcli.ps1')
  }
}

output out object = dsAzCli.properties.outputs
