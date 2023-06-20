param servicebusNamespaceName string
param topicName string
param subscriptionCount int = 1

resource sub 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = [for i in range(0,subscriptionCount): {
  name: '${servicebusNamespaceName}/${topicName}/subby-${i}'
  properties: {}
}]
