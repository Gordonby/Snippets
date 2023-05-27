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

Consumption 
| summarize max(Consumed) by HouseholdId, Timestamp, MeterType
| summarize sum(max_Consumed) by  MeterType
| join Costs on MeterType
| summarize sum(sum_max_Consumed * Cost)
