# Detective season 2

## 1

```kql
DetectiveCases
| distinct EventType
//CaseAssigned CaseUnsolved CaseSolved CaseOpened

let bounty= DetectiveCases
| extend b=parse_json(Properties)
| where EventType == 'CaseOpened'
| project CaseId, b.Bounty;

DetectiveCases 
| join bounty on CaseId
| where EventType == 'CaseSolved'
| summarize count(b_Bounty), sum(toint(b_Bounty)) by DetectiveId
| order by sum_b_Bounty desc 
```

## 2

```kql
Consumption 
| summarize max(Consumed) by HouseholdId, Timestamp, MeterType
| summarize sum(max_Consumed) by  MeterType
| join Costs on MeterType
| summarize sum(sum_max_Consumed * Cost)
```

## 3

```kql
PhoneCalls
| distinct EventType

let disconnections = PhoneCalls
| where EventType == 'Disconnect'
| project CallEnd=Timestamp, EventType, CallConnectionId, DisconnectedBy=Properties.DisconnectedBy;
PhoneCalls
| where EventType == 'Connect'
| join kind=inner disconnections on CallConnectionId 
| project CallStart=Timestamp, CallConnectionId, Origin=tostring(Properties.Origin), Properties.Destination, IsHidden=toboolean(Properties.IsHidden), CallEnd, DisconnectedBy=tostring(DisconnectedBy), CallLength=CallEnd-Timestamp
| where DisconnectedBy=='Destination'
| where IsHidden==true
| summarize calls=count() by bin(CallLength, 1min), Origin
| sort by calls
| take 100
```

## 4

```kql
StolenCars | take 50

let lastKnownLocationStolen=CarsTraffic
| summarize arg_max(Timestamp, Ave, Street) by VIN
| join StolenCars on VIN;
let CarsLastLog=CarsTraffic
| summarize arg_max(Timestamp, Ave, Street) by VIN;
let CarsFirstLog=CarsTraffic
| summarize arg_min(Timestamp, Ave, Street) by VIN;
lastKnownLocationStolen
| join CarsFirstLog on Ave, Street 
| where Timestamp1 > Timestamp
| extend TimeStampDiffHours=datetime_diff('hour',Timestamp1,Timestamp)
| where TimeStampDiffHours <=2
| join CarsLastLog on $left.VIN2==$right.VIN
```

## 5

```kql
IpInfo
| take 10

NetworkMetrics | take 10

NetworkMetrics | 
summarize TotalNewConnections=sum(NewConnections), sum(BytesReceived), sum(BytesSent) by ClientIP |
evaluate ipv4_lookup(IpInfo, ClientIP, IpCidr) |
summarize sum(sum_BytesReceived), sum(sum_BytesSent), sum(TotalNewConnections) by Info |
order by sum_TotalNewConnections


NetworkMetrics | 
where NewConnections==1 |
summarize TotalBytesReceived=sum(BytesReceived) by ClientIP |
evaluate ipv4_lookup(IpInfo, ClientIP, IpCidr) |
order by TotalBytesReceived desc
```
