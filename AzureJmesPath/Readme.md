# Jmespath sample snippets

## Azure DevOps
```bash
az devops project show -p $project --query "[id, name]" -o tsv

az pipelines variable-group list --query "[?name=='AZURECREDENTIALS_CANARY'].{Id:id}" -o tsv

az devops user list --top 1 --query members[0].id -o tsv


```

## AKS

```bash
RG=""
AKSNAME=""

az aks show -n $AKSNAME -g $RG -o json --query "{clusterId:identity.userAssignedIdentities ,kubeletId:identityProfile.kubeletidentity.clientId}"
az aks show -n $AKSNAME -g $RG -o json --query "{clusterId:identity.userAssignedIdentities.*.principalId ,kubeletId:identityProfile.kubeletidentity.clientId}"
```

## Az Accounts

```bash
az account list --all --query "[].{name:name,id:id}"
```

## Application Gateway

```bash
az network application-gateway show -n $appgwname -g $appgwrg --query "frontendIpConfigurations[]"
az network application-gateway show -n $appgwname -g $appgwrg --query "[frontendIpConfigurations[].name]"
az network application-gateway show -n $appgwname -g $appgwrg --query "frontendIpConfigurations[].{id:id, privateIp:privateIpAddress}"
az network application-gateway show -n $appgwname -g $appgwrg --query "frontendIpConfigurations[].{id:id, name:name, privateIp:privateIpAddress}"
az network application-gateway show -n $appgwname -g $appgwrg --query "frontendIpConfigurations[?privateIpAddress==null].{id:id, name:name, privateIp:privateIpAddress}"

```


## Features

```bash
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService')].{Name:name,State:properties.state}"
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService') && properties.state=='Registering'].{Name:name,State:properties.state}"
```
