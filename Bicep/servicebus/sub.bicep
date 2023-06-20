param servicebusNamespaceName string
param topicName string
param subscriptions array = ['asubscription','anotherone']

resource sub 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = [for i in subscriptions: {
  name: '${servicebusNamespaceName}/${topicName}/subby-${i}'
  properties: {}
}]
