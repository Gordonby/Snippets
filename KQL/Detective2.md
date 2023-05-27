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
