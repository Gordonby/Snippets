# flux

## cheatsheet

List flux configurations

```bash
az k8s-configuration flux list -c $AKSNAME -g $RG -t managedClusters -o table
az k8s-configuration flux show -n bootstrap -c $AKSNAME -g $RG -t managedClusters -o table
```


```bash
az k8s-configuration flux kustomization list -g $RG -c $AKSNAME -n bootstrap -t managedClusters
```
