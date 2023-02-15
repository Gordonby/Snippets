
## Unique daily users over 60 days with trendline

```kql
let usg_events = dynamic(["*"]);
let grain = iff(true, 1d, 1h);
let mainTable = union pageViews, customEvents, requests
    | where timestamp > ago(60d)
    | where isempty(operation_SyntheticSource)
    | extend name =replace("\n", "", name)
    | extend name =replace("\r", "", name)
    | where '*' in (usg_events) or name in (usg_events);
let resultTable = mainTable;
resultTable
| make-series Users = dcountif(user_Id, 'user_Id' != 'user_AuthenticatedId' or ('user_Id' == 'user_AuthenticatedId' and isnotempty(user_Id))) default = 0 on timestamp from ago(60d) to now() step grain
| extend AverageBaseline = toint(series_stats_dynamic(Users).avg)
| render timechart 
```
