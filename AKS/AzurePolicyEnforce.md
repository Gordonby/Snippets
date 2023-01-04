# Azure Policy Enforcement demo

## Create cluster

I used [AKSC](https://azure.github.io/AKS-Construction/?ops=none&secure=low&addons.azurepolicy=deny&addons.azurePolicyInitiative=Restricted&deploy.clusterName=policytest&deploy.rg=innerloop) to create a cluster of the correct spec.

```bash
# Create Resource Group
az group create -l WestEurope -n innerloop

# Deploy template with in-line parameters
az deployment group create -g innerloop  --template-uri https://github.com/Azure/AKS-Construction/releases/download/0.9.6/main.json --parameters \
	resourceName=policytest \
	JustUseSystemPool=true \
	azurepolicy=deny \
	azurePolicyInitiative=Restricted
```

## Create pod

```bash
kubectl run -i --tty --rm bashdebug --image=ubuntu:latest --privileged=true --restart=Never -- bash
```

