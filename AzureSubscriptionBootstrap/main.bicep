targetScope='subscription'

param location string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'automation'
  location: location
  tags: {
    Cleanup:'Never'
  }
}

module automation 'automation.bicep' = {
  scope: resourceGroup(rg.name)
  name: '${deployment().name}-automation'
  params: {
    location: location
  }
}
