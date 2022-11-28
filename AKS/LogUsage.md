# AKS Container Insights Log Usage

I have an AKS cluster that is doing a lot of logging!

The cluster has 2 nodepools, each with 1 node.
The cluster runs a couple of workloads of low demand usage.

The compute cost is quite low as i'm using B-series VM's;

![image](https://user-images.githubusercontent.com/17914476/204270750-99800751-ed72-48a5-9dcf-2827ed679153.png)

The logging cost racks in at $66

![image](https://user-images.githubusercontent.com/17914476/204271127-877806e5-412d-4421-80e5-852d9da72ba2.png)


## Investigating the log usage

To get a view of which Logging Solution is generating the most data i can run;

```kql
Usage
| where TimeGenerated > startofday(ago(31d))
| where StartTime > startofday(ago(31d))
| where IsBillable == true
| summarize TotalVolumeGB = sum(Quantity) / 1000 by bin(StartTime, 1d), Solution
| render columnchart
```

![image](https://user-images.githubusercontent.com/17914476/204271385-e1284ccd-84c9-48f8-a991-137608305204.png)

So we can see that most of the data is being generated in the `Log Management` solution.

To drilldown and inspect what DataTypes are taking up the space i can run;

```kql
Usage
| where TimeGenerated > startofday(ago(31d))
| where StartTime > startofday(ago(31d))
| where IsBillable == true
| where Solution == 'LogManagement'
| summarize TotalVolumeGB = sum(Quantity) / 1000 by bin(StartTime, 1d), DataType
| render columnchart
```

![image](https://user-images.githubusercontent.com/17914476/204271655-68782069-8400-4476-924f-7c09e7f059ac.png)

We can see that most of the data is related to AzureDiagnostics.
To drilldown further we need to change to this datatable.

This query will count the rows and group by Category. The category will relate directly to the AKS Cluster logging categories.

```kql
AzureDiagnostics
| summarize count() by Category
| sort by count_
| render piechart 
```

```output
kube-audit-admin 338,523
cluster-autoscaler 67,094
kube-controller-manager 5,013
guard 331
```

![image](https://user-images.githubusercontent.com/17914476/204272148-a697150d-c9e9-4f15-887e-057832bc7ae9.png)

The next point in the drilldown is to understand what's going into this datatable and the value it brings.

It's worth pausing and looking at what the kube-audit-admin category is.
Is a subset of the kube-audit log category. kube-audit-admin reduces the number of logs significantly by excluding the get and list audit events from the log.
It's therefore worth considering the diagnostic value, and the fact that when there are events that need to be investigated if you've unknowingly disabled this logging category.

```kql
AzureDiagnostics
| where Category == 'kube-audit-admin'
| summarize count() by substring(pod_s,0,14), OperationName
```

We can see that `kube-apiserver` is performing the `Microsoft.ContainerService/managedClusters/diagnosticLogs/Read` operation 338,771 times (in the last 24 hours).
Lets keep going and see what's actually being logged.

```kql
AzureDiagnostics
| where Category == 'kube-audit-admin'
| project TimeGenerated, log_s
| extend e=parse_json(log_s) 
| project TimeGenerated, e.kind, userAgent=substring(e.userAgent,0,50), requestUri=substring(e.requestURI,0,100)
| summarize count() by tostring(userAgent), tostring(requestUri)
| sort by count_
| take 10


//Looking at specific data
AzureDiagnostics
| where Category == 'kube-audit-admin'
| project TimeGenerated, log_s
| extend e=parse_json(log_s) 
| where e.userAgent startswith "kube-scheduler/v1.23.12"
| take 20
```

This returns

![image](https://user-images.githubusercontent.com/17914476/204278422-c9fb793f-9feb-493f-8293-65b15f442770.png)

The immediate quick win here is for me to disable the Disk CSI driver, because the only CSI driver i'm using for my workloads is File.
