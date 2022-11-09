
## 2

```kql
//Find a specific book
Books
| where book_title == 'De Revolutionibus Magnis Data'

//Shelf data
Shelves
| take 5

//Which shelf is a book on
Shelves
| mv-expand rf_ids
| extend rf_ids =tostring(rf_ids)
| join Books on $left.rf_ids == $right.rf_id
| project book_title, shelf
| take 5

//Which books aren't on shelves
Shelves
| mv-expand rf_ids
| extend rf_ids =tostring(rf_ids)
| join kind=rightouter Books on $left.rf_ids == $right.rf_id
| where isnull(shelf)
| take 5
| project book_title, shelf


// Shelf weight vs Book lookup weight
Shelves
| mv-expand rf_ids
| extend rf_ids =tostring(rf_ids)
| join kind=inner Books on $left.rf_ids == $right.rf_id
| summarize rfIdbookWeight=sum(weight_gram) by shelf, total_weight

// Which shelves have weight dicrepancies
Shelves
| mv-expand rf_ids
| extend rf_ids =tostring(rf_ids)
| join kind=inner Books on $left.rf_ids == $right.rf_id
| summarize rfIdbookWeight=sum(weight_gram) by shelf, total_weight
| extend dicrepancy = (total_weight - rfIdbookWeight)
| order by dicrepancy desc 
| take 5
```

## 3

```kql

//Votes data
Votes | take 5

//Vote count
Votes
| summarize Count=count() by vote
| as hint.materialized=true T
| extend Total = toscalar(T | summarize sum(Count))
| project vote, Percentage = round(Count*100.0 / Total, 1), Count
| order by Count

//Votes by "via-ip"
Votes
|summarize count() by via_ip
|order by count_ asc

//Votes by HashId (Suspicious multi-vote hypothesis)
Votes
|summarize count() by voter_hash_id, vote
|where count_ > 1
|order by count_ asc

//Votes for poppy
Votes 
| where vote == 'Poppy'
| order by Timestamp
| take 100

//Candidate votes by ip
Votes
| summarize count() by vote, via_ip
| order by via_ip desc

//Time difference in votes
Votes
| summarize min(Timestamp), max(Timestamp), count() by vote, via_ip
| extend timeDiff = max_Timestamp - min_Timestamp
| order by count_ desc

//Raw Votes for poppy for specific IP
Votes
| where vote == 'Poppy'
| where via_ip == '10.168.36.21'
| order by Timestamp

//Bucket time to find problems
Votes
| where vote == 'Poppy'
| where via_ip == '10.168.36.21'
| summarize count() by bin(Timestamp, 1m)

//Bucket time to find average vote/minute among all candidates
Votes
| summarize count() by vote, via_ip, bin(Timestamp, 1m)
| summarize avg(count_), max(count_) by vote

//Analyse Suspicious time periods
Votes
| summarize count() by vote, via_ip, bin(Timestamp, 1m)
| where count_ > 5
| order by count_ asc 

//Real vote criteria
Votes
| summarize count() by vote, via_ip, bin(Timestamp, 1m)
| where count_ <5
| summarize Count=count() by vote
| as hint.materialized=true T
| extend Total = toscalar(T | summarize sum(Count))
| project vote, Percentage = round(Count*100.0 / Total, 1), Count
| order by Count

//Ok, that method wasn't right... reboot.

//Downscope to 1 second from 1 minute
Votes
| summarize count() by vote, via_ip, bin(Timestamp, 1s)
| summarize avg(count_), max(count_) by vote

//Analyse Suspicious time periods
Votes
| summarize count() by vote, via_ip, bin(Timestamp, 1s)
| where count_ > 2
| order by count_ asc 

//Analyse Suspicious time periods
//Real vote criteria
Votes
| summarize count() by vote, via_ip, bin(Timestamp, 1s)
| where count_ <3
| summarize Count=count() by vote
| as hint.materialized=true T
| extend Total = toscalar(T | summarize sum(Count))
| project vote, Percentage = round(Count*100.0 / Total, 1), Count
| order by Count
```

## 4

```kql
//check fields
Traffic
| take 5

//get traffic data for when gang leave
//for area near bank (bank located at 157th Ave / 148th Street)
let bankCars = Traffic
| where Timestamp between(datetime(2022-10-16T08:31:00Z) .. datetime(2022-10-16T08:40:00Z))
| where Ave == 157
| where Street == 148
| project VIN
| distinct VIN;

//we need to grab traffic data to focus on end location now
//filtering by the dataset above
Traffic
| where VIN in (bankCars)
| where Timestamp between(datetime(2022-10-16T08:40:00Z) .. datetime(2022-10-16T11:00:00Z))
| summarize count() by Ave, Street
| where count_ > 2
| order by count_ desc 

//too much data :( 1442 results

//trying arg_max (which seems to return the maximum value of a column)
let bankCars = Traffic
| where Timestamp between(datetime(2022-10-16T08:31:00Z) .. datetime(2022-10-16T08:40:00Z))
| where Ave == 157
| where Street == 148
| project VIN
| distinct VIN;
Traffic
| where Timestamp between(datetime(2022-10-16T08:40:00Z) .. datetime(2022-10-16T11:00:00Z))
| where VIN in (bankCars)
| summarize carStopDriving = arg_max(Timestamp, *) by VIN
| summarize carCount = count() by Ave, Street
| where carCount >= 3
```

## 5 

```kql
.execute database script <|
.create-merge table Prime(primey:long)
.ingest into table Prime ('https://kustodetectiveagency.blob.core.windows.net/prime-numbers/prime-numbers.csv.gz') with (ignoreFirstRecord=false)


Prime
| sort by primey asc 
| take 10

//specials
Prime
| sort by primey asc 
| extend prev1 = prev(primey,1) 
| extend prev2 = prev(primey,2) 
| extend specialIs = prev1 + prev2 + 1
| take 10

Prime
| sort by primey asc 
| extend prev1 = prev(primey,1) 
| extend prev2 = prev(primey,2) 
| extend specialIs = prev1 + prev2 + 1
| where specialIs < 100000000
| sort by specialIs desc
| take 10

Prime
| sort by primey asc 
| extend prev1 = prev(primey,1) 
| extend prev2 = prev(primey,2) 
| extend specialIs = prev1 + primey + 1
| project specialIs
| where  specialIs < 100000000
| order by specialIs desc 
| take 5


let specials = Prime
| sort by primey asc 
| extend prev1 = prev(primey,1) 
| extend prev2 = prev(primey,2) 
//| extend specialIs = prev1 + prev2 + 1 // two neighboring prime numbers and 1
| extend specialIs = prev1 + primey + 1 //this seems to be one neighbouring number, itself and 1. weird. but works.
| project specialIs;
Prime
| join specials on $left.primey == $right.specialIs
| where specialIs < 100000000
| order by primey desc 
| take 5

```
