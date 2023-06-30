param clusterName string = 'clusterNameA'
param databaseName string = 'databaseNameA'
param aadTenantId string = subscription().tenantId
param databasePrincipalAssignments array = [
  {
    principalId: 'id1'
    role: 'Viewer'
    principalType: 'App'
  }
  {
    principalId: 'id2'
    role: 'Ingestor'
    principalType: 'App'
  }
  {
    principalId: 'id3'
    role: 'Admin'
    principalType: 'App'
  }        
]

resource assignment 'Microsoft.Kusto/clusters/databases/principalAssignments@2022-02-01' = [for (item, i) in databasePrincipalAssignments: {
  name: '${clusterName}/${databaseName}/${item.principalId}_${item.principalType}_${item.role}_${i}'
  properties: {
    principalId: item.principalId
    role: item.role
    tenantId: aadTenantId
    principalType: item.principalType
  }
}]
