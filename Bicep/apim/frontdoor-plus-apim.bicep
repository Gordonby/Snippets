@description('Used in the naming of Az resources')
@minLength(3)
param nameSeed string

module apim './apim.bicep' = {
  name: 'addAksNetContributor'
  params: {
    nameSeed: nameSeed
  }
}

resource fd 'Microsoft.Network/frontDoors@2020-05-01' = {
  name: 'fd'
  properties: {
    friendlyName: nameSeed

  }
}
