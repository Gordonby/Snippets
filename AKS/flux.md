# flux

## cheatsheet

List flux configurations

```powershell
az k8s-configuration flux list -c $AKSNAME -g $RG -t managedClusters -o table
az k8s-configuration flux show -n bootstrap -c $AKSNAME -g $RG -t managedClusters -o table
```


```powershell
az k8s-configuration flux kustomization list -g $RG -c $AKSNAME -n bootstrap -t managedClusters
```

## debug experience

After deploying the AKS Baseline Flux Configuration, kustomization is left in a pending state.

![image](https://user-images.githubusercontent.com/17914476/170984481-d4189456-fbcd-49af-a08b-71990246fcc7.png)

```powershell
flux logs -A

✗ a container name must be specified for pod fluxconfig-agent-6476794446-94ph5, choose one of: [fluxconfig-agent fluent-bit]
```

```powershell
kubectl get events -A

NAMESPACE                   LAST SEEN   TYPE      REASON              OBJECT                            MESSAGE
cluster-baseline-settings   29m         Warning   FailedScheduling    pod/mic-74df7dcbc5-2kdk5          0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector.
cluster-baseline-settings   28m         Warning   FailedScheduling    pod/mic-74df7dcbc5-tlcgb          0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector.
flux-system                 4m37s       Warning   HealthCheckFailed   kustomization/bootstrap-unified   (combined from similar events): Health check failed after 5m0.015112257s, timeout waiting for: [Deployment/cluster-baseline-settings/mic status: 'Failed']
flux-system                 4m58s       Normal    ArtifactUpToDate    gitrepository/bootstrap           artifact up-to-date with remote revision: 'main/ed6277fa843567c90d912b9a13771a29e0175936'
```

```powershell
get po -n cluster-baseline-settings

NAME                   READY   STATUS    RESTARTS   AGE
kured-29xtk            1/1     Running   0          118m
mic-74df7dcbc5-2kdk5   0/1     Pending   0          118m
mic-74df7dcbc5-tlcgb   0/1     Pending   0          118m
```

```powershell
 kubectl describe po mic-74df7dcbc5-2kdk5 -n cluster-baseline-settings | sls "Node-Selectors" -context 1
 
 > Node-Selectors:              agentpool=npuser01
                               kubernetes.io/os=linux
```

Looks like i'm missing the node pool 😄

![image](https://user-images.githubusercontent.com/17914476/170987440-4d090336-6123-4eb8-b10d-59c9fb999453.png)
