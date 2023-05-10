# Troubleshooting AKS CSI Disk error

## The error

```output
prometheus      2m30s       Normal    ExternalProvisioning   persistentvolumeclaim/my-prometheus-server                  
   waiting for a volume to be created, either by external provisioner "disk.csi.azure.com" or manually created by system administrator
```

## The underlying problem

I opted out of the CSI disk driver as none of the existing workloads on the cluster required it.

## The fix

```bash
az aks update -n <clustername> -g <resourcegroup> --enable-disk-driver
```
