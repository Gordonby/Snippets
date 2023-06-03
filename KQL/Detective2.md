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
