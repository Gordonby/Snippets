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
