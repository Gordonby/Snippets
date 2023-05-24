resource dd 'Microsoft.Datadog/monitors@2022-06-01' = {
  name: 'dd1'
  location: 'westus2'
  properties: {
    datadogOrganizationProperties: {
      name: 'Microsoft'

    }
    monitoringStatus: 'Disabled'
    userInfo: {
      emailAddress: 'gobyers@microsoft.com'
      name: 'Gordon'
      phoneNumber: '555-555-5555'
    }
  }
  sku: { name:'payg_v2_Monthly'}
}
