

## Creating a test cluster

Using AKSC, I'll create a cluster in a region where i have NVidia VM compute availability.

```bash
az deployment group create -g akspersist  --template-uri https://github.com/Azure/AKS-Construction/releases/download/0.9.6/main.json -p resourceName=kubegeneralus agentCount=1 custom_vnet=true CreateNetworkSecurityGroups=true location=westcentralus
```
