# Safe to Evict

This uses the [Azure Vote App manifest](https://github.com/Gordonby/Snippets/blob/master/AKS/Azure-Vote-UnsafeToEvict.yml) (2 deployment) to demonstrate the safe-to-evict automation using the Azure Automation Account.

App Deployment | Replicas | Pod Disruption Budget | Safe to Evict
-------------- | -------- | --------------------- | -------------
Azure Vote Front | 3 | MaxUnavailable = 1 | True
Azure Vote Back | 1 | | False

The scenario is that the Azure Vote Back pods may be badly placed on a node that the Kubernetes Cluster AutoScaler (CA) wishes to scale down.

> "Cluster Autoscaler decreases the size of the cluster when some nodes are consistently unneeded for a significant amount of time. A node is unneeded when it has low utilization and all of its important pods can be moved elsewhere."  [ref](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#when-does-cluster-autoscaler-change-the-size-of-a-cluster)

The Safe To Evict Annotation has been applied to the Azure Vote Back.

## Scenario

The scenario is that we'd like the Cluster Autoscaler to be able to perform its unneeded node evaluation on nodes that the Azure Vote Back app is using, but only during specific hours of the day.

> The scenario is somewhat of an anti-pattern, and is documented for very specific scenarios that require this behaviour.

## Sample

Let's create

1. An AKS cluster
2. An Azure Automation account with the [safe-to-evict runbook](https://github.com/Gordonby/aks-cluster-pod-evict)
3. An Azure Automation schedule to call the runbook at specific times

Here are the observations

1. 
