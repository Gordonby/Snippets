

## Creating a test cluster

Using [AKSC](https://azure.github.io/AKS-Construction/?ops=none&secure=low&deploy.rg=akspersist&deploy.clusterName=nvidiatest&cluster.SystemPoolType=none&cluster.agentCount=1&net.vnet_opt=custom&net.nsg=true&deploy.location=WestCentralUS&cluster.vmSize=Standard_NV6_Promo), I'll create a cluster in a region where i have NVidia VM compute availability.

```bash
az deployment group create -g akspersist  --template-uri https://github.com/Azure/AKS-Construction/releases/download/0.9.9/main.json --parameters \
	resourceName=nvidiatest \
	agentCount=1 \
	JustUseSystemPool=true \
	agentVMSize=standard_nc4as_t4_v3 \
	custom_vnet=true \
	omsagent=true \
	retentionInDays=30
```

## Connect to the cluster

```bash
az aks get-credentials -g akspersist -n aks-nvidiatest --admin --overwrite-existing

kubectl get nodes
```

## Checking the driver version

Run this command to connect to the node, and inspect the Nvidia current driver version.

```bash
NODENAME=$(kubectl get nodes -o=jsonpath='{.items[0].metadata.name}')
kubectl debug node/$NODENAME -it --image=ubuntu:latest
```

Then we can check the file system at;

```bash
ls host/var/lib/dkms/nvidia/
```

### Check GPUs are not currently schedulable

```bash
kubectl describe nodes | grep nvidia.com/gpu:
```

This shows that GPU's are not schedulable

![image](https://user-images.githubusercontent.com/17914476/218768561-970891f7-8575-4ab7-92df-9cae6ac46046.png)


### Creating the nvidia device plugin

```bash
kubectl create ns gpu-resources
kubectl apply -f nvidiapluginaks.yml
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/main/nvidia-device-plugin.yml
```

### Check GPUs are schedulable

```bash
kubectl describe nodes | grep nvidia.com/gpu:
```

You should find that they are now schedulable

![image](https://user-images.githubusercontent.com/17914476/218795713-d0ebb2ef-d4a5-4d6e-bc01-2d85a1f5fb1f.png)


## Update node labels to specify desired driver version

```bash
NODEPOOLNAME=$(az aks nodepool list -g akspersist --cluster-name aks-nvidiatest --query [0].name -o tsv)
az aks nodepool update -g akspersist --cluster-name aks-nvidiatest -n $NODEPOOLNAME --labels nvidiaDriver=515.65.01
```


![image](https://user-images.githubusercontent.com/17914476/210365588-116a64be-8d22-42f9-aa03-1bd7de1234bd.png)

## Replacing the driver

### AdHoc daemonset

Starting out with alexeldeib's gist - we can download and customise this yaml file to replace the drivers. This way to deploy does not leverage the node label we added earlier (that gets used by the helm chart), all config is set in the script itself.
https://gist.github.com/Gordonby/d330b451218f6d1a5e1fcafee272bc3e

![image](https://user-images.githubusercontent.com/17914476/210591639-e033e38d-f9d6-4c80-be27-fca2172ccf25.png)


### Helm chart

Refining the yaml file above a little results in a [small helm chart](https://github.com/Gordonby/minihelm/tree/main/samples/gpu-drivers). This helm chart can be installed on the cluster, easily varying the behaviour by tweaking the chart values.

```bash
helm upgrade --install gpudrivers525 https://github.com/Gordonby/minihelm/raw/main/samples/gpu-drivers-0.1.6.tgz -n nvidiadriver --create-namespace --set gpuDriverVersion=525.60.13
helm upgrade --install gpudrivers515 https://github.com/Gordonby/minihelm/raw/main/samples/gpu-drivers-0.1.6.tgz -n nvidiadriver --create-namespace --set gpuDriverVersion=515.65.01

kubectl get all -n nvidiadriver
```

![image](https://user-images.githubusercontent.com/17914476/210781836-83b33ef9-267f-4891-9f9f-cbd63932422f.png)

![image](https://user-images.githubusercontent.com/17914476/210781901-da8f5f3d-649f-41e7-a890-49937a9b4ef9.png)

![image](https://user-images.githubusercontent.com/17914476/210782129-a1d141b0-371b-495f-8312-be93f1685738.png)

## Checking the driver version (again!)

Run this command to connect to the node, and inspect the Nvidia current driver version.

```bash
NODENAME=$(kubectl get nodes -o=jsonpath='{.items[0].metadata.name}')
kubectl debug node/$NODENAME -it --image=ubuntu:latest
```

Then we can check the file system at;

```bash
ls host/var/lib/dkms/nvidia/
```

## Troubleshooting

### Nc6 VM Size

![image](https://user-images.githubusercontent.com/17914476/210595684-63b7888c-d788-4664-aeac-41030a20636d.png)

