

## Creating a test cluster

Using [AKSC](https://azure.github.io/AKS-Construction/?ops=none&secure=low&deploy.rg=akspersist&deploy.clusterName=nvidiatest&cluster.SystemPoolType=none&cluster.agentCount=1&net.vnet_opt=custom&net.nsg=true&deploy.location=WestCentralUS&cluster.vmSize=Standard_NV6_Promo), I'll create a cluster in a region where i have NVidia VM compute availability.

```bash
az deployment group create -g akspersist  --template-uri https://github.com/Azure/AKS-Construction/releases/download/0.9.6/main.json --parameters \
	resourceName=nvidiatest \
	agentCount=1 \
	JustUseSystemPool=true \
	agentVMSize=Standard_NV6_Promo \
	custom_vnet=true
```

## Connect to the cluster

```bash
az aks get-credentials -g akspersist -n aks-nvidiatest --admin

kubectl get nodes
```

## Checking the driver version

Run this command to connect to the node, and inspect the Nvidia current driver version.

```bash
kubectl debug node/aks-agentpool-53828973-vmss000000 -it --image=ubuntu:latest
```

Then we can check the file system at;

![image](https://user-images.githubusercontent.com/17914476/210365588-116a64be-8d22-42f9-aa03-1bd7de1234bd.png)

## Replacing the driver

### AdHoc daemonset

Starting out with alexeldeib's gist - we can download and customise this yaml file to replace the drivers
https://gist.github.com/Gordonby/d330b451218f6d1a5e1fcafee272bc3e

### Helm chart

Refining the yaml file above a little results in a [small helm chart](https://github.com/Gordonby/minihelm/tree/gb-nvidia/samples/gpu-drivers). This helm chart can be installed on the cluster, easily varying the behaviour by tweaking the chart values.

