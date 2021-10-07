@description('Used to name the resources')
param nameseed string = 'aitestvnext'


param type string = 'web'
param location string = resourceGroup().location
param requestSource string ='rest'
param workspaceResourceId string = ''

@allowed([
    'Bluefield'
    'Redfield'
])
param flowtype string = 'Bluefield'

resource law 'Microsoft.OperationalInsights/workspaces@2021-06-01' = if (empty(workspaceResourceId)) {
  name: 'log-${nameseed}'
  location: location
  properties: {
    retentionInDays: 30
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${nameseed}'
  location: location
  kind: type
  properties: {
    Application_Type: type
    Flow_Type: flowtype
    Request_Source: requestSource
    WorkspaceResourceId: empty(workspaceResourceId) ? law.id : workspaceResourceId
  }
}
