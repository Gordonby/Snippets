# Cheatsheet

## bootstrap

```bash
alias k="kubectl"
NAMESPACE="default"
k config set-context --current --namespace=$NAMESPACE
```

## delete first pod in namespace, wait and grab logs from newly created pod

```bash
PODNAME=$(k get po -o=jsonpath='{.items[0].metadata.name}') && k delete po $PODNAME && sleep 5s && PODNAME=$(k get po -o=jsonpath='{.items[0].metadata.name}') && k logs $PODNAME
```

## edit configmap with nano

```bash
KUBE_EDITOR="nano" kubectl edit configmap/gpudrivers515-gpu-drivers-script
```


## debug as priviledged

```bash
kubectl run -i --tty --rm debug2 --image=mcr.microsoft.com/aks/e2e/library-busybox:master.210526.1 --restart=Never --overrides='{"spec": {"template": {"spec": {"containers": [{"securityContext": {"privileged": true} }]}}}}' -- sh
```

## get decoded secrets

```
kubectl get secrets/minecraft-storage-secret -n minecraft -o json | jq '.data | map_values(@base64d)'
```

## scale up the nodepools

```powershell
Write-Output "Scaling $AKSNAME in $RG"

$manualScalePools = az aks show -n $AKSNAME -g $RG --query "agentPoolProfiles[?maxCount==null].{name:name, count:count}" -o json | ConvertFrom-Json
$manualScalePools | ForEach-Object { 
    Write-Output "scaling [m] pool $($_.name)"
    az aks scale -g $RG -n $AKSNAME --node-count $($_.pool + 1) --nodepool-name $_.name 
}

$autoScalePools = az aks show -n $AKSNAME -g $RG --query "agentPoolProfiles[?maxCount!=null].{name:name, minCount:minCount, maxCount:maxCount}" -o json | ConvertFrom-Json
$autoScalePools | ForEach-Object {
    Write-Output "scaling [a] pool $($_.name)"
    az aks nodepool update -g $RG --cluster-name $AKSNAME --name $_.name --min-count $($_.minCount + 1) --max-count $($_.maxCount + 1) --update-cluster-autoscaler
}
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

## ubuntu for running bash

```bash
kubectl run -i --tty --rm bashdebug --image=ubuntu:latest --restart=Never -- bash
```

## Create Namespace if exists

```bash
kubectl create namespace $NAMESP --dry-run=client -o yaml | kubectl apply -f -
```
