# SMB Demo

The process for standing up a non Azure native SMB target for a Kubernetes workload.

## Create the VM with SMB share

Create a Windows virtual machine (portal/iac/script/etc)

Modify the variables in this [powershell script file](https://github.com/Gordonby/Snippets/blob/master/AzureVMCustomScriptExtension/Windows-CreateSmbShare.md), then run on the VM to create the share file and create a user/password combo that has access.

## Create an AKS cluster

An easy way is to use the [AKS Construction project](https://github.com/Azure/Aks-Construction).

## Configure the cluster - SMB

Install the SMB CSI driver, and create the Persistent Volume.

https://github.com/Gordonby/Snippets/blob/master/AKS/Smb-Demo-Pt1.sh

## Deploy the workload

https://github.com/Gordonby/Snippets/blob/master/AKS/Smb-Demo-Pt2.yaml

## Verify

Look at th VM share to ensure the files have been created from the container
