

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


## Checking the driver version

Grab the node name with `kubectl get nodes` then run this command with the name to check the host node for the current driver version.

```bash
kubectl debug node/aks-agentpool-53828973-vmss000000 -it --image=ubuntu:latest
```

Then we can check the file system at;

![image](https://user-images.githubusercontent.com/17914476/210365588-116a64be-8d22-42f9-aa03-1bd7de1234bd.png)
