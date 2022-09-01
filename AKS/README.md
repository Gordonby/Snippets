# Cheatsheet

## scale up the nodepools

```powershell
$manualScalePools = az aks show -n $AKSNAME -g $RG --query "agentPoolProfiles[?maxCount==null].{name:name, count:count}" -o json | ConvertFrom-Json
$manualScalePools | % { echo "scaling $($_.name)"; az aks scale --resource-group $RG --name $AKSNAME --node-count $($_.pool + 1) --nodepool-name $_.name }

$autoScalePools = az aks show -n $AKSNAME -g $RG --query "agentPoolProfiles[?maxCount!=null].{name:name, minCount:minCount, maxCount:maxCount}" -o json | ConvertFrom-Json
$autoScalePools | % { echo "scaling $($_.name)"; az aks nodepool update -g $RG -n $AKSNAME --name $_.name --min-count $($_.minCount + 1) --maxCount $($_.maxCount + 1)

```

## connect to the last aks cluster in the list

```bash
akslist=$(az aks list --query "[].{name:name,resourceGroup:resourceGroup}" -o json);read AKSNAME RG < <(echo $(echo $akslist | jq -r ".[-1].name, .[-1].resourceGroup"))
az aks get-credentials -n $AKSNAME -g $RG --overwrite-existing
```

## get events by timestamp

```bash
kubectl get events --sort-by='.metadata.creationTimestamp' -A
```


## getting pod->node scheduling info

```bash
kubectl get pods -o=json | jq -r '.items[] | [.metadata.name,.spec.tolerations,.status.containerStatuses[].name]'
```

## grabbing a service ip address with jsonpath and jq

```bash
> kubectl get svc -l app=selenium-hub -o=jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}'
20.103.140.69

> kubectl get svc -l app=selenium-hub -o json | jq -r '.items[0].status.loadBalancer.ingress[0].ip'
20.103.140.69
```


## secret value (when there's only 1 secret data in the k8s secret

```bash
kubectl get secret mysecretname -o jsonpath='{.data.*}' | base64 --decode
```

## change service type

```bash
kubectl patch svc myservice  -p '{"spec": {"type": "LoadBalancer"}}'

kubectl patch svc myservice  -p '{"spec": {"type": "ClusterIP"}}'
```

## lookup images in the mcr (good for when behind az fw)

```bash
wget -O - https://mcr.microsoft.com/v2/_catalog | grep busybox
wget -O - https://mcr.microsoft.com/v2/aks/e2e/library-busybox/tags/list
```

## busybox for debugging.  ping/dns/wget-magic :D

```bash
kubectl run -i --tty --rm debug --image=mcr.microsoft.com/aks/e2e/library-busybox:master.210526.1 --restart=Never -- sh
```

## Create Namespace if exists

```bash
kubectl create namespace $NAMESP --dry-run=client -o yaml | kubectl apply -f -
```
