# Azure Policy Enforcement demo

These scripts show the creation of an AKS cluster and Azure Policy Deny effects.

Note
1. [Azure Policy uses Gatekeeper](https://learn.microsoft.com/azure/governance/policy/concepts/policy-for-kubernetes) which runs in cluster to enforce rules as an admission controller 
2. Gatekeeper has a `fail open` behaviour as described [here](https://learn.microsoft.com/azure/governance/policy/troubleshoot/general#scenario-kubernetes-resource-gets-created-during-connectivity-failure-despite-deny-policy-being-assigned)
3. There is a delay post cluster creation of ~15 minutes before Azure Policy/Gatekeeper

## Create cluster

I used [AKSC](https://azure.github.io/AKS-Construction/?ops=none&secure=low&addons.azurepolicy=deny&addons.azurePolicyInitiative=Restricted&deploy.clusterName=policytest&deploy.rg=innerloop) to create a cluster of the correct spec. The bicep used for the Policy assignment can be seen [here](https://github.com/Azure/AKS-Construction/blob/839b85d7268cd5af7a823ecd5b55df7b0ca41b1e/bicep/main.bicep#L1331)

```bash
# Create Resource Group
az group create -l WestEurope -n innerloop

# Deploy template with in-line parameters
az deployment group create -g innerloop  --template-uri https://github.com/Azure/AKS-Construction/releases/download/0.9.6/main.json --parameters \
	resourceName=policytest \
	JustUseSystemPool=true \
	azurepolicy=deny \
	azurePolicyInitiative=Restricted
	
az aks get-credentials -g innerloop -n aks-policytest

```

## Wait

It takes a little time before Azure Policy integrates with the new cluster.

![image](https://user-images.githubusercontent.com/17914476/210520198-56011e27-e0b3-4ff0-b99d-ef9dc317e4aa.png)

![image](https://user-images.githubusercontent.com/17914476/210520366-1f9d7e82-8187-44c1-b64f-fbee7c66b24f.png)

### Timeline

- 04/01/2023, 08:57:42 : deployment started
- +3min 47s : deployment completed
- + ~ 15mins : policy registered

![image](https://user-images.githubusercontent.com/17914476/210522374-e70d1098-3f6e-430f-a396-55293e2769ac.png)

## Create pod

```bash
kubectl run -i --tty --rm bashdebug --image=ubuntu:latest --privileged=true --restart=Never -- bash
```

![image](https://user-images.githubusercontent.com/17914476/210522526-93f536c6-6ca2-44d1-bdad-bf73a2ff3f97.png)

## Observed Behaviour

Any priviledged pods created between cluster creation and azure policy enforcement will not be killed, their established sessions will continue to run
