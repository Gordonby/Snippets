

## Install Kubernetes

```bash
RG="gordons"
az deployment group create -g $RG  --template-uri https://github.com/Azure/AKS-Construction/releases/download/0.9.9/main.json --parameters \
	resourceName=nvidiatest \
	agentCount=1 \
	JustUseSystemPool=true \
	agentVMSize=standard_nc4as_t4_v3 \
	custom_vnet=true \
	omsagent=true \
	retentionInDays=30 \
  location=eastus
```
  
## Check the driver version

```bash
az aks get-credentials -g $RG -n aks-nvidiatest --admin --overwrite-existing
NODENAME=$(kubectl get nodes -o=jsonpath='{.items[0].metadata.name}')
kubectl debug node/$NODENAME -it --image=ubuntu:latest

#Then run this in the node debug
ls host/var/lib/dkms/nvidia/
```

![image](https://user-images.githubusercontent.com/17914476/219675952-743f1827-8d45-4b14-97a1-429c24733f11.png)

## Install NVIDIA GPU Operator

```bash
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update
helm upgrade --install --wait nvidiagpuop \
   -n gpu-operator --create-namespace \
   nvidia/gpu-operator \
   --set driver.repository=docker.io/nvidia \
   --set driver.version="515.65.01" \
   --set toolkit.enabled=true \
   --set psp.enabled=false \
   --set nfd.enabled=true

 kubectl get pods -n gpu-operator
 ```
 
![image](https://user-images.githubusercontent.com/17914476/219662036-c565fbfa-3a98-48b9-8219-2b28ab9acb4b.png)

![image](https://user-images.githubusercontent.com/17914476/219662712-215de4ef-0a7d-4a4c-9abd-9b2765ac07b1.png)


## Observe Node Labels

```bash
kubectl describe nodes | grep nvidia.com/
```

If the node has pre-installed drivers then driver upgrading will be disabled. Ref: [Nvidia datacenter GPU operator driver release notes](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/release-notes.html#id19)

We can see that the AKS nodes are indeed labelled with `pre-installed`

![image](https://user-images.githubusercontent.com/17914476/219664990-56aeacc0-87c4-4172-887d-1a285c828179.png)

This [GitHub issue](https://github.com/NVIDIA/gpu-operator/issues/476) indicates that this is not a scenario that GPU Operator caters for;

 
### Attempted Workaround

In order to get GPU Operator controlling the nvidia plugin version AND the driver version, we can try a version of GPU Operator before the `pre-installed` check was added (v1.11.0).

![image](https://user-images.githubusercontent.com/17914476/219666911-062bcd36-1f60-4d80-9428-c63ed7c12f08.png)

```bash


```

```bash
helm upgrade --install --wait nvidiagpuop \
   -n gpu-operator --create-namespace \
   nvidia/gpu-operator --version v1.11.0 \
   --set driver.repository=docker.io/nvidia \
   --set driver.version="515.65.01" 
```

The node labels from v1.11.0;

![image](https://user-images.githubusercontent.com/17914476/219676287-2279215f-6ecb-4022-8f23-b5f3519cacd0.png)

![image](https://user-images.githubusercontent.com/17914476/219676669-973ec1a5-de28-4f55-9b96-e2a1cdd29090.png)

So it looks like the upgrade is just skipped. 
The new `pre-installed` label is not added, but the behaviour is unchanged.
