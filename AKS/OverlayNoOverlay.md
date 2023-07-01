# Overlay, No-Overlay

Script showing the creation of an AKS cluster with overlay networking, then disabling overlay and going back to regular CNI.

## Cluster setup

Using the [AKS Construction IaC](https://azure.github.io/AKS-Construction/?env=Dev&net.networkPluginMode=true&net.vnetAksSubnetAddressPrefix=10.240.0.0%2F24&net.podCidr=10.244.0.0%2F16&secure=low&ops=none&deploy.rg=innerloop&deploy.clusterName=nooverlay&net.vnet_opt=custom) to quickly create an Overlay cluster

```bash
az group create -l WestEurope -n innerloop

# Deploy template with in-line parameters
az deployment group create -g innerloop  --template-uri https://github.com/Azure/AKS-Construction/releases/download/0.10.0/main.json --parameters \
        resourceName=nooverlay \
        agentCount=1 \
        JustUseSystemPool=true \
        osDiskType=Managed \
        osDiskSizeGB=32 \
        custom_vnet=true \
        networkPluginMode=Overlay \
        automationAccountScheduledStartStop=Weekday
```

## Validating cluster config

