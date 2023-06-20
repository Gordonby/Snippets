param serviceBusName string = 'sbgordtest'
param location string = resourceGroup().location

resource serviceBus_resource  'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
}
