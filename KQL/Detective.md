
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
```
