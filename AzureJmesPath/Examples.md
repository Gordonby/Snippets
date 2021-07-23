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
