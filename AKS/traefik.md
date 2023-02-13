



```bash
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik --namespace=traefik --create-namespace
```

### Errors on windows

```output
Events:
  Type     Reason       Age                  From               Message
  ----     ------       ----                 ----               -------
  Normal   Scheduled    47m                  default-scheduler  Successfully assigned ingress-basic/traefik-74f9fbfc5d-2j2r8 to aksnpwin1000000
  Warning  FailedMount  47m                  kubelet            MountVolume.SetUp failed for volume "kube-api-access-vdmm9" : chown c:\var\lib\kubelet\pods\a9bc7231-e1e8-4492-9163-4bc449235494\volumes\kubernetes.io~projected\kube-api-access-vdmm9\..2023_02_06_10_08_01.3747695922\token: not supported by windows
  Warning  FailedMount  47m                  kubelet            MountVolume.SetUp failed for volume "kube-api-access-vdmm9" : chown c:\var\lib\kubelet\pods\a9bc7231-e1e8-4492-9163-4bc449235494\volumes\kubernetes.io~projected\kube-api-access-vdmm9\..2023_02_06_10_08_02.3702552909\token: not supported by windows
  Warning  FailedMount  47m                  kubelet            MountVolume.SetUp failed for volume "kube-api-access-vdmm9" : chown c:\var\lib\kubelet\pods\a9bc7231-e1e8-4492-9163-4bc449235494\volumes\kubernetes.io~projected\kube-api-access-vdmm9\..2023_02_06_10_08_03.3734272409\token: not supported by windows
  Warning  FailedMount  47m                  kubelet            MountVolume.SetUp failed for volume "kube-api-access-vdmm9" : chown c:\var\lib\kubelet\pods\a9bc7231-e1e8-4492-9163-4bc449235494\volumes\kubernetes.io~projected\kube-api-access-vdmm9\..2023_02_06_10_08_05.2494815654\token: not supported by windows
  Warning  FailedMount  47m                  kubelet            MountVolume.SetUp failed for volume "kube-api-access-vdmm9" : chown c:\var\lib\kubelet\pods\a9bc7231-e1e8-4492-9163-4bc449235494\volumes\kubernetes.io~projected\kube-api-access-vdmm9\..2023_02_06_10_08_09.3643449744\token: not supported by windows
  Warning  FailedMount  47m                  kubelet            MountVolume.SetUp failed for volume "kube-api-access-vdmm9" : chown c:\var\lib\kubelet\pods\a9bc7231-e1e8-4492-9163-4bc449235494\volumes\kubernetes.io~projected\kube-api-access-vdmm9\..2023_02_06_10_08_17.3048927259\token: not supported by windows
  Warning  FailedMount  47m                  kubelet            MountVolume.SetUp failed for volume "kube-api-access-vdmm9" : chown c:\var\lib\kubelet\pods\a9bc7231-e1e8-4492-9163-4bc449235494\volumes\kubernetes.io~projected\kube-api-access-vdmm9\..2023_02_06_10_08_33.3990286863\token: not supported by windows
  Warning  FailedMount  46m                  kubelet            MountVolume.SetUp failed for volume "kube-api-access-vdmm9" : chown c:\var\lib\kubelet\pods\a9bc7231-e1e8-4492-9163-4bc449235494\volumes\kubernetes.io~projected\kube-api-access-vdmm9\..2023_02_06_10_09_05.629790654\token: not supported by windows
  Warning  FailedMount  11m (x5 over 45m)    kubelet            Unable to attach or mount volumes: unmounted volumes=[kube-api-access-vdmm9], unattached volumes=[data tmp kube-api-access-vdmm9]: timed out waiting for the condition
  Warning  FailedMount  7m19s (x6 over 41m)  kubelet            Unable to attach or mount volumes: unmounted volumes=[kube-api-access-vdmm9], unattached volumes=[tmp kube-api-access-vdmm9 data]: timed out waiting for the condition
  Warning  FailedMount  51s (x32 over 45m)   kubelet            (combined from similar events): MountVolume.SetUp failed for volume "kube-api-access-vdmm9" : chown c:\var\lib\kubelet\pods\a9bc7231-e1e8-4492-9163-4bc449235494\volumes\kubernetes.io~projected\kube-api-access-vdmm9\..2023_02_06_10_54_55.2757684707\token: not supported by windows
  ```



### Using AKSC

Cluster creation with [AKS Construction](https://azure.github.io/AKS-Construction/?ops=none&secure=low&deploy.rg=gordons&deploy.clusterName=gbwin&cluster.SystemPoolType=CostOptimised&cluster.osType=Windows&cluster.nodepoolName=npwin1&cluster.vmSize=Standard_DS4_v2&cluster.osSKU=Windows2022&cluster.agentCount=1&addons.ingress=traefik&deploy.kubernetesVersion=1.25.5).

```bash
# Create Resource Group
az group create -l WestEurope -n gordons

# Deploy template with in-line parameters
az deployment group create -g gordons  --template-uri https://github.com/Azure/AKS-Construction/releases/download/0.9.9/main.json --parameters \
	resourceName=gbwin \
	kubernetesVersion=1.25.5 \
	agentCount=1 \
	agentVMSize=Standard_DS4_v2 \
	nodePoolName=npwin1 \
	osType=Windows \
	osSKU=Windows2022

# Get credentials for your new AKS cluster & login (interactive)
az aks get-credentials -g gordons -n aks-gbwin
kubectl get nodes

# Deploy charts into cluster
curl -sL https://github.com/Azure/AKS-Construction/releases/download/0.9.9/postdeploy.sh  | bash -s -- -r https://github.com/Azure/AKS-Construction/releases/download/0.9.9 \
	-p ingress=traefik
```
