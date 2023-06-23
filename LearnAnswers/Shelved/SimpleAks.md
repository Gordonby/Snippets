This might seem like a complex way to solve a simple problem, however **simplicity**, **privacy** and **low-cost** does seem to be an iron triangle.

The Azure Kubernetes Service is a Container Orchestrator that has a full feature set, and you also only pay for the underlying VM compute.

This means that with a simply-configured AKS service, you will have a low-cost, private container environment.

I'm part of a team that has created a Microsoft AKS Accelerator for creating the environments (and no, I'm not therefore trying to solve every problems with AKS, my first answer to this question was Container Apps).  

If you navigate to the [Helper app for the accelerator](https://azure.github.io/AKS-Construction/?ops=none&secure=low&env=Dev&deploy.clusterName=simplecontainerhost&deploy.rg=rg&cluster.vmSize=Standard_D4plds_v5&cluster.osDiskType=Ephemeral&cluster.upgradeChannel=stable&net.vnet_opt=custom), you'll see a preconfigured low-cost environment. It uses Azure Automation to stop and start each day, private networking, and just 1 cheap VM (feel free to change to another VM SKU).

Once you've run the generated deploy command, you can then deploy your container to the cluster.

