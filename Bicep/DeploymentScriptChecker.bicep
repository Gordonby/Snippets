@description('The location of the ACR and where to deploy the module resources to')
param location string = resourceGroup().location

@description('How the deployment script should be forced to execute')
param forceUpdateTag  string = utcNow()

@description('A delay before the script import operation starts. Primarily to allow Azure AAD Role Assignments to propagate')
param initialScriptDelay string = '10s'

@allowed([
  'OnSuccess'
  'OnExpiration'
  'Always'
])
@description('When the script resource is cleaned up')
param cleanupPreference string = 'Always'

resource createImportImage 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'Check-Prerequisites'
  location: location
  kind: 'AzureCLI'
  properties: {
    forceUpdateTag: forceUpdateTag
    azCliVersion: '2.30.0'
    timeout: 'PT5M'
    retentionInterval: 'P1D'
    environmentVariables: [
      {
        name: 'initialDelay'
        value: initialScriptDelay
      }
    ]
    scriptContent: '''
      echo "sleeping for $initialDelay"
      sleep $initialDelay

      echo "Path variables"
      echo $PATH

      echo "AZ CLI version"
      az --version
    '''
    cleanupPreference: cleanupPreference
  }
}
