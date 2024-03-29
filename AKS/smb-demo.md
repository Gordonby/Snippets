# SMB Demo

The process for standing up a non Azure native SMB target for a Kubernetes workload.

## Create the VM with SMB share

Create a Windows virtual machine (portal/iac/script/etc)

Modify the variables in this [powershell script file](https://github.com/Gordonby/Snippets/blob/master/AzureVMCustomScriptExtension/Windows-CreateSmbShare.md), then run on the VM to create the share file and create a user/password combo that has access.

## Create an AKS cluster

An easy way is to use the [AKS Construction project](https://github.com/Azure/Aks-Construction).

## Add AKS secret for SMB credentials

Using the same user/password, as you gave permissions on the share; Create a Kubernetes Secret to be leveraged by the Persistent Volume.

```bash
kubectl create secret generic smbcreds --from-literal username=user4 --from-literal password="zeP4ssW0RD%%"
```

## Configure the cluster - SMB

Install the SMB CSI driver, and create the Persistent Volume.

https://github.com/Gordonby/Snippets/blob/master/AKS/Smb-Demo-Pt1.sh

## Inspect the Persistent Volume and Secret

```bash
kubectl get pv
kubectl get secrets
```

## Deploy the workload

```bash
kubectl apply -f https://raw.githubusercontent.com/Gordonby/Snippets/master/AKS/Smb-Demo-Pt2.yaml
```

## Verify

Verify the deployed smb pod is running. It will be creating files in the smb share

```bash
kubectl get po
```

Look at the VM share to ensure the files have been created from the container. 
The file name will contain the pod name
![image](https://user-images.githubusercontent.com/17914476/151969003-3b49356b-25cc-4032-8d3e-e22aad3940fa.png)

## Scale up

Scale the number of replicas

```bash
kubectl scale --replicas=4 deployment deployment-smb
```

You'll see the replicas created and new files also

![image](https://user-images.githubusercontent.com/17914476/151969793-a0634200-04c8-4b75-b77f-d6874ec0d12a.png)
