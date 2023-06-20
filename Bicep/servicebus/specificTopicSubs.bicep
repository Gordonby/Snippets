@description('Name of the Service Bus namespace')
param serviceBusNamespaceName string

@description('Name of the Topic')
param topicsAndSubscriptions array = [
  {
    name: 'notification'
    subscriptions: [
      'none'
      'ntwo'
      'nthree'
      'nfour'
    ]
  }
  {
    name: 'analysis'
    subscriptions: [
      'aone'
      'atwo'
      'athree'
      'afour'
    ]
  }
]

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource serviceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = [ for topic in topicsAndSubscriptions: {
  parent: serviceBusNamespace
  name: topic.name
  properties: {

  }
}]

module subs 'sub.bicep' = [ for topic in topicsAndSubscriptions: {
  name: '${topic.name}-subs'
  params: {
    servicebusNamespaceName: serviceBusNamespaceName
    topicName: topic.name
    subscriptions: topic.subscriptions
  }
}]

