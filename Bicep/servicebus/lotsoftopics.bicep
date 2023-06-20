@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('Name of the Topic')
param serviceBusTopicName string = 'theweather'

param topicSubscriptions int = 3

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource serviceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  parent: serviceBusNamespace
  name: serviceBusTopicName
  properties: {

  }

  resource sub 'subscriptions' = [for i in range(0,topicSubscriptions): {
    name: 'sub-${i}'
    properties: {}
  }]
}
