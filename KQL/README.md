
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
