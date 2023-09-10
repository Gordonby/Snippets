# Useful KQL snippets

## VM RDP connections

Azure Monitor Virtual Machine Insights logging to a Log Analytics Workspace puts the relevant data into `VMConnection`.

```kql
VMConnection
| where Direction == "inbound"
| where Protocol == "tcp"
| where DestinationPort == 3389
| summarize FirstEvent = min(TimeGenerated), LastEvent = max(TimeGenerated),NumberOfConnections = count() by Computer, RemoteIp
```

## Kubernetes clusters - all clusters, nodes used

```kql
resources
| where type == "microsoft.containerservice/managedclusters"
| project name, location, K8SVersion=properties.kubernetesVersion, NodePools=properties.agentPoolProfiles
| mv-expand NodePools
| project name, location, VmSku=tostring(NodePools.vmSize), OsDiskSize=tostring(NodePools.osDiskSizeGB), OsDiskType=tostring(NodePools.osDiskType), PoolMode=tostring(NodePools.mode), Instances=toint(NodePools.['count'])
| summarize sum(Instances) by VmSku
```

## Azure Activity - Top change Authors 

```kql
let adu = datatable(AadResolvedName:string, objid:string)
[
 "Azure Security RP","2d9f1d0a-c6db-430a-a031-6b5dce2c5382",
 "Microsoft Defender", "3d9f1d0a-c6db-430a-a031-6b5dce2c5382",
 "Windows 365", "4d9f1d0a-c6db-430a-a031-6b5dce2c5382",
];
AzureActivity
| where OperationNameValue endswith_cs "/WRITE"
| where Level == 'Information'
| where ActivityStatusValue == 'Accept'
| join kind=leftouter adu on $left.Caller==$right.objid
| distinct CorrelationId, AADUser=iif(AadResolvedName=="", Caller, AadResolvedName), CallerIpAddress, SubscriptionId, OperationNameValue
| summarize count() by AADUser
| sort by count_ desc
| take 20
```

## Activity Logs - Deployments, distinct resources created. (per user/day)

```kql
AzureActivity
| where OperationNameValue == 'MICROSOFT.RESOURCES/DEPLOYMENTS/WRITE'
| where Level == 'Information'
| extend props=parse_json(Properties)
| project TimeGenerated, ResourceGroup, Caller, Resource=tostring(props.resource)
| summarize DistinctResources=dcount(Resource), Deployments=count() by Caller, Day=bin(TimeGenerated, 1d)
| sort by Day desc 
```

## Activity Logs - Deployments per user, per RG, per day

```kql
AzureActivity
| where OperationNameValue == 'MICROSOFT.RESOURCES/DEPLOYMENTS/WRITE'
| where Level == 'Information'
| extend props=parse_json(Properties)
| project TimeGenerated, ResourceGroup, Caller, Resource=props.resource
| summarize count() by ResourceGroup, Caller, Day=bin(TimeGenerated, 1d)
```

## Checking if a table exists

```kql
let hasNonEmptyTable = (T:string) 
{ 
   toscalar( union isfuzzy=true ( table(T) | count as Count ), (print Count=0) | summarize sum(Count) ) > 0
};
let TableName = 'KubeServices';
print Table=TableName, IsPresent=iif(hasNonEmptyTable(TableName), 1, 0)
```

```kql
let hasNonEmptyTable = (T:string) { toscalar( union isfuzzy=true ( table(T) | count as Count ), (print Count=0) | summarize sum(Count) ) > 0 };
print hasNonEmptyTable('KubeService')
```

## AKS - Summarise images used by count desc

```kql
ContainerInventory |
summarize count() by Repository, Image, ImageTag
```

## AKS Container Logs - calculating start times from log times

```kql
ContainerLog
| where LogEntry == 'Starting Bedrock server...' or LogEntry endswith 'Server started.'
| project TimeGenerated, LogEntry
| serialize TimeGenerated, LogEntry, SecondsToStart=datetime_diff('second', TimeGenerated, prev(TimeGenerated,1))
| where LogEntry endswith 'Server started.' and SecondsToStart > 0
| sort by TimeGenerated asc 
| project format_datetime(TimeGenerated, 'yyyy-MM-dd'), SecondsToStart
| render columnchart 
```
