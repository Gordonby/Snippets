
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

## 6

```kql
//Split users, ips and channels to picture the users session
let leftChannel = ChatLogs
| where Message startswith "User "
| where Message contains 'left the channel'
| extend event = 'left'
| extend user = substring(Message, 6,11)
| extend channel = substring(Message, 37, 11)
| project Timestamp, event, user, channel ;
let sentToChannel = ChatLogs
| where Message startswith "User "
| where Message contains 'sent message to the channel'
| extend event = 'sentmsg'
| extend user = substring(Message, 6,11)
| extend channel = substring(Message, 48, 11)
| project Timestamp, event, user, channel ;
let geoData =
materialize (externaldata(network:string,geoname_id:string,continent_code:string,continent_name:string,
country_iso_code:string,country_name:string,is_anonymous_proxy:string,is_satellite_provider:string)
[@"https://raw.githubusercontent.com/datasets/geoip2-ipv4/master/data/geoip2-ipv4.csv"] with
(ignoreFirstRecord=true, format="csv"));
let userLogout = ChatLogs
| where Message startswith "User "
| where Message contains 'logged out from'
| extend event = 'logout'
| extend user = substring(Message, 6,11)
| project Timestamp, event, user ;
let userLogin = ChatLogs
| where Message startswith "User "
| where Message contains 'logged in from'
| extend event = 'login'
| extend user = substring(Message, 6,11)
| extend ip = replace_regex(substring(Message, 34),"'","")
//| evaluate ipv4_lookup(geoData, ip, network)
| project Timestamp, event, user, ip ;
let joinedChannel = ChatLogs
| where Message startswith "User "
| where Message contains 'joined the channel'
| extend event = 'joined'
| extend user = substring(Message, 6,11)
| extend channel = substring(Message, 39,11)
| project Timestamp, event, user, channel ;
let session = userLogin
| union joinedChannel, userLogout, sentToChannel, leftChannel
| sort by user, Timestamp asc
| extend rn=row_number()
| extend counterbase= iif(event=='login',1,1)
| extend eventStep=row_cumsum(counterbase,event == 'login')
| extend sessionId = iif(event=='login',rn,rn-eventStep+1);
session
| take 10;
// let suspiciousChannels = session
// | summarize count(), didJoin=countif(event=='joined'), didSent=countif(event=='sentmsg'), user=max(user), ip=max(ip), channel=max(channel), min(Timestamp), max(Timestamp), JoinTime=minif(Timestamp, event=='joined') by sessionId
// | where didJoin >0
// | order by sessionId asc
// | summarize count(user) by channel, bin(min_Timestamp,2m)
// | where count_user == 4
// | distinct channel;
let suspiciousChannelTimes = session
| where event == 'joined'
| summarize count(user) by channel, bin(Timestamp, 1m)
| where count_user ==4
| project channel, timebin=Timestamp;
let suspiciousChannels = suspiciousChannelTimes
| distinct channel;
session
| where event == 'joined'
| where channel in (suspiciousChannelTimes)
| distinct channel, user
| summarize distinctChannelUsers=count() by channel;
session
| summarize count(), didJoin=countif(event=='joined'), didSent=countif(event=='sentmsg'), user=max(user), ip=max(ip), channel=max(channel), min(Timestamp), max(Timestamp), JoinTime=minif(Timestamp, event=='joined') by sessionId
| where channel == "cf053de3c7b"
| distinct ip
```
