# Service Fabric using Service Bus Queues through MSI

## Objective
Testing out using MSI from within Service Fabric Web and API apps.

## References
https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-managed-service-identity
https://github.com/Azure/azure-service-bus/tree/master/samples/DotNet/Microsoft.ServiceBus.Messaging/ManagedServiceIdentity

## Pre-requisites
1. In the Azure Portal, on the VM Scaleset that your Service fabric cluster uses, go *Configuration* and enable MSI.
1. In the Azure Portal, on the Service bus you want to add a message to, go *IAM* and add the name of your VM Scaleset (eg. NodeType1) as an *Owner*

## The packages
1. Microsoft.Azure.Services.AppAuthentication v1.1.0-preview
1. Microsoft.IdentityModel.Clients.ActiveDirectory 3.14.2
1. Newtonsoft.Json (latest)
1. System.IdentityModel.Tokens.Jwt v4.0.4.403061554
1. WindowsAzure.ServiceBus v4.2.2-preview
