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

## 6

```kql
let spikeyHosts=StorageArchiveLogs
    | parse EventText with "Read blob transaction: '" BlobURI "' read access (" ReadCount:long " reads) were detected on the origin"
    | extend Host = tostring(parse_url(BlobURI).Host) 
    | summarize sum(ReadCount) by Host, Day=bin(Timestamp, 1d)
    | where sum_ReadCount > 1000 //spikes
    | distinct Host;
let totalBlobReads=StorageArchiveLogs
    | parse EventText with "Read blob transaction: '" BlobURI "' read access (" ReadCount:long " reads) were detected on the origin"
    | summarize BlobReads=sum(ReadCount) by BlobURI;
let CreatedBlobs=StorageArchiveLogs
    | parse EventText with TransactionType " blob transaction: '" BlobURI "' backup is created on " bkp
    | extend Host = tostring(parse_url(BlobURI).Host) 
    | where Host in (spikeyHosts)
    | where TransactionType == 'Create'
    | project CreateDate=Timestamp, BlobURI, bkp;
StorageArchiveLogs
    | parse EventText with TransactionType " blob transaction: '" BlobURI "'" *
    | extend Host = tostring(parse_url(BlobURI).Host) 
    | where TransactionType == 'Delete'
    | join CreatedBlobs on BlobURI
    | join kind=leftouter totalBlobReads on BlobURI //leftouter as maybe zero read transactions
    | project Life=datetime_diff('minute',Timestamp,CreateDate), BlobReads, BlobURI, Host, CreateDate,bkp
    | where Life < 500 //500 minutes from create to delete, not sure why i chose 500 :D
    | sort by BlobReads asc, Life asc
    | take 20 //top 20 culprits
```

## 7

```kql
// Hint1 : Can you find 41701/11 this word is located in the 131736/0 data?
// First part is the ObjectId, and the second relates to a field... Could be one of the many text fields but only ProvenanceText is not null for both books and has 11 words
NationalGalleryArt
| where ObjectId==41701 or ObjectId==131736
| project ObjectId, Word = extract_all(@'(\w+)', ProvenanceText)
| mv-expand with_itemindex=index Word
| extend ObjectWord = strcat(tostring(ObjectId), '/', index)
| where ObjectWord=='41701/11' or ObjectWord=='131736/0'
// Can you find WHERE this word is located in the MUSEUM data?
```

## 8 

```kql
Flights
| take 5

Airports
| take 5

//Doha Airports
Airports 
| where municipality  == 'Doha'

//Potential Doha planes used to escape
let PointsNearBy = (Lon1:double, Lat1:double, Lon2:double, Lat2:double, s2_precision:int)
{
    geo_point_to_s2cell(Lon1, Lat1, s2_precision) ==
    geo_point_to_s2cell(Lon2, Lat2, s2_precision) 
};
let EscapePlanes=Flights
| where PointsNearBy(lon, lat, 51.608056, 25.273056, s2_precision = 13) // Level: 13 is ~1km
| where Timestamp between(datetime(2023-08-11T03:30:00Z) .. datetime(2023-08-11T05:30:00Z))
| where onground==true
| distinct callsign;
Flights
| where Timestamp > datetime(2023-08-11T05:30:00Z)
| where callsign in (EscapePlanes)
| where onground==true
| order by callsign
//| summarize planeLanded = arg_max(Timestamp, *) by VIN


Airports
| where municipality == "Doha"
| extend geos2=geo_point_to_s2cell(lon, lat)

Flights
| where Timestamp between (datetime(2023-08-11 3:30) .. datetime(2023-08-11 5:30))
| where onground == true
| extend geos2=geo_point_to_s2cell(lon, lat)
| where geos2 == "3e45c8c" //Doha
| distinct callsign

let AboutToTakeOff = Flights
| where Timestamp between (datetime(2023-08-11 3:30) .. datetime(2023-08-11 5:30))
| where onground == true //on ground so he can board at airport
| extend geos2=geo_point_to_s2cell(lon, lat)
| where geos2 == "3e45c8c" //Doha
| distinct callsign;
Flights
| extend geos2=geo_point_to_s2cell(lon, lat)
| where callsign in (AboutToTakeOff)
| where Timestamp > datetime(2023-08-11 05:30)
| join kind=inner (
    Flights
        | extend geos2=geo_point_to_s2cell(lon, lat)
        ) on geos2, Timestamp
| where callsign <> callsign1 //this whole join and difference makes a weird fuzzy dataset to try to join to other aircraft.. getting a bit lost on how to match otherwise. match with other planes at the same place and time
| extend AltitudeDiff = geoaltitude - geoaltitude1
| where round(heading - heading1,0) == 0 //planes are pointing in the same direction, to a degree of precision anyway ()
| where round(velocity - velocity1,0) == 0 // planes are speed matched
| where AltitudeDiff < 2500 //planes are close
| project callsign, callsign1

Flights
| where callsign in ("OJIT393" , "HFID97")
| extend geos2=geo_point_to_s2cell(lon, lat)
| where onground == true
| summarize min(Timestamp) by callsign, geos2

Airports
| extend geos2=geo_point_to_s2cell(lon, lat)
| where geos2=="486711c" or geos2 == "12a49e4"
| distinct Name, municipality
```

## 9

some weird suduko bullshit going on here :D.

```kql
// Secret Message intercepted    
let city_code=datatable(c1:long,c2:long,c3:long,c4:long)
[1, 14, 14,  4, 
 11, 7, 6,  9,
 8, 10, 10, 5,
 13, 2, 3, 15];  
print Key=SecretCodeToKey(city_code), Message=
@'0SOHpSdTgidfqXFOYeIOjktOjXFcjktPjwzHgSABgsctZknJZKfEjBAygipOgS\\pBNEjknCVedTpSdyjk7EZKFHVSOa8i7E8SOCZedfgSOTgSA'
@'tYPFaYB4TjXFHZ[\OVkNT17mzgSv\VPFHjknHjKFnVedygSvuVBvOYBxDgS4HgiztVkAyYyFujPFupwgEpiztjKFmVaIOVaImV[nHgS\\pBNEYB'
@'d\Z[\OjXFb8SNEjk4yYyFujPFb8SNEKbIFqEbo7adbgSjOZwgEVBAbqXFc6KFDVeO\VXFCV[tyZkIOYyfEjBAygipOgiv5Zk2DgSnupXFeZwjOY'
@'PFBYBAcgSAtYPFfZwI5gKFzjPF\VaOb8SOTjyfEp[NEY[\\VSfE8knbjknH8kjngSAtYPFOjBjuYaIHgidTpSODgiI5jKFqIssEZeztVkzDjwME'
@'ZBdTjk4b8XFupwgEjBdOpXxvXJJEZ[4TVBAbgiv5ZwzOgiIuVyFcpkv5gS4bgiI58wMEpSOcjKfEZadbgizOYe7EZwvHpwzOjXfEp[NEZwzOgiz'
@'tVBnmVBYEVedygXzHVkAQjKFbjwvbYygDgSzupSEEjBOapwz\pSO[jk2ngS4TjXF2pkObjKFD8wIOYB4DViJT17mN8Sdngiv5Zk2DgSdxYSAHjK'
@'Fb8SNEKbIFzeMEp[d\8[nOYevOYyF\VB7E8SdyZk2JgSObYyFOYSOCgSIup[nBZk2DqEbo17mUVeYDgS2OpXFtYyF\jSIyjwvHgiI5jKFcZwIbj'
@'wgEV[ZEVwJEp[dDVXtPjkOTjyxEKKFtVBIOYavbZknJgiI5Zw7EpS\OYBNE8wMEZKFaYBd\pXFJjk4DgSABgSvtYBOuY[Ob6KFyjkp\YBImVBYE'
@'VwJEY[4BjwInqPrvXJ2OpXFcjKF\YevtYBNE6kAtqXFmpXFeZwMEZk2DgSsEVk4bpSdygSABgSOcYSdCZ[4PVSNEpSOc8knaqPFUVyFJVedPpXF'
@'c6KFCV[nTjkvb8knagSjD8kp5pXFeZwMEZkxEjw\fjwzmjknCjKFujPF\gS2mjBdb8ktOg7bodSAugSz\jXFc6KFDpkpaZkpOgSj\8k2OjXFbVy'
@'FlV[OTgStOgSATgiI58wMEpS\y8k2D8knagSmupwzTjwJ\g15m175vXJztpXFBjk4ygSnupXfEVwJEjazmjknJYyfEVSd\pBOTjyFb8SOTjeMEp'
@'SREZ[\\VBvOgSOHgSnupXFc6KFHpiODjKxEKKF5ZwjOgS4HY[dcZB2OjXF\giIOZkbEV[ZEVSAnZkfEZBAJ6kptZwzJYyfvXap5VyFcVejOgipm'
@'pSEEVkNEVSOQjKFOVidH8wjOgiF5ZknbV[tHqXFOVavtYBOTjyFc6KFmVajmVBvmZBOD8wInqPFFpXF\VaJEj[O[jkxEpSOcjKfEZw7EVSd\Ye7'
@'EpipugSABgiI5jkbEjSOHZezOjwID67boY[\\jSAegStngSd[jwzngStupBNDgSd[jkxEjidy8knagStngSdx8SODZwz\pSOTjyFypknHgiI5YB'
@'Atj[EEpS\OgSvmpiJTg4Iypk2nqXFzgSjOjkfEpknbVedC8S4PVSNTgs4TjXFDjw7EVkNEpSdDVXFnVeND17mb8SOHgSvmpiJE8wMEZKF58kIJj'
@'kxEj[dcgKFzpXFujBjOYaMEZkxEZkztVBI\VBvOgSABgSt\YajOVSAtYyFHYSAbYyFe8SdyjKFuVBNEZ[4TgSOTjidDj[NE8kxEZKFyjkjyjwv5'
@'8knagiv5ZkcOgS4BpSdy17mCV[n2pkdy8knagSsEZazOZwI5pS4Q8knag1sfKyFypkxTgsObgSOHgSsEYSdyjBdCpXFPVSdTjXFujPFc8wvC8SO'
@'OjPF\VB7EYBdlpwjOVB4b8kATqXF\gSIOVSOa8iIBpkfEZ[ATZ[ACpSOuVPFb8S4bgSjtjk2HgStngivbYBdTjeI5qEbo17m0VyfEVwJEjBdDVS'
@'AegizujedOYyfEVSdbgidHgScOjwrEVedygSdnjwMEjBOxjk7EV[xEpS\OgiI\YBpOpXxEKKFe8k2DgizOpBd\VXFcVezOgSIOpS4mViMEZkzup'
@'w7EVedygiFDZknHgSOTgSItjKFb8ktOqPrvXOFyjwF\YBNE6kAtYavOVijOYyFbVyFe8wITjwvHgiI5jKFHYSdCpS4Cpk2\YPFJVepTjB4DVXFu'
@'jPFb8SNEKbIFqXF\YyFejKFyjk2OVaIDjwvHViJEjizmVSfE8knbVyFmpiMEZ[AyjKF\pXFBpk2DgivfjkdJg7bogrboKeznYiIu'
| invoke Dekrypt()
| project Result
```

## 11

```kql
KuandaLogs
| take 50

KuandaLogs
| summarize count() by Message

KuandaLogs
| extend messagewords = split(Message, ' ')
| extend firstword = tostring(messagewords[0])
| summarize count(), take_any(Message) by firstword //take_any Arbitrarily chooses one record for each group
//Operation	343178
//User	662084
//Sending	192

//Dekrypt function is bering used, but needs a user token. (DetectiveId == user)
Dekrypt(@'3sO9bqbkbBHkbUg7bUeibs0ibs0ybB09bB09bLXYONkKW3zHWxGs1wm61wOca8vFYwmy13ecW3Ec1wmTpdOynfEce6K4pf9cY67cpwvsYZGkh3YTWwuoOlQKafGs1wm61wmsOIu4ONLVuZG9a8Qq1wVspdmsOIu4OlL6p6oHOIuR1wVoOIVzaduopxGRW3SFaTN=', 
strcat_array(<active-user-encryption-tokens>, ''))

//users
KuandaLogs
| extend messagewords = split(Message, ' ')
| extend firstword = tostring(messagewords[0])
| where firstword == "User"
| summarize count() by Message

//sending (Dekrypt function)
KuandaLogs
| extend messagewords = split(Message, ' ')
| extend firstword = tostring(messagewords[0])
| where firstword == "Sending"
| summarize count() by Message

//Operations
KuandaLogs
| parse Message with "Operation id=" startOpID " started ('" CaseStatus "'). Captured user encryption token: '" token "'."
| parse Message with "Operation id=" completeOpID " completed: user encryption token for this operation is disposed."
| partition hint.strategy=native by DetectiveId //Totes stole this partition bit.
(
    order by Timestamp asc
    | scan with_match_id=id  declare(OperationId2Token:dynamic) with (
        step start:
            Message has 'User entered the system' or 
		    Message has 'User session reset' =>
		    OperationId2Token = dynamic({}) // Initialize
		    ;
		step capture: 
		  Message has 'Captured user encryption token' or Message has "completed" => 		  
		  OperationId2Token = 
		      iff(Message has 'Captured user encryption token', 
		          bag_merge(capture.OperationId2Token, bag_pack(startOpID, token)),      // If add token
		          bag_remove_keys(capture.OperationId2Token, pack_array(completeOpID)))  // Else, invalidate token
		  ;
		step end:
		 Message has 'Sending' => 
		  OperationId2Token = capture.OperationId2Token
		  ;
    )
   | order by id asc, Timestamp asc
)
| extend TotalKey = strcat_array(extract_all(@':\"([a-z]*)\",?', tostring(OperationId2Token)), "")
// Parsing the encrypted message
| parse-where Message with "Sending an encrypted message, will use Dekrypt(@'" Encrypted "', strcat_array(<active-user-encryption-tokens>, '')) for decoding."
| project DetectiveId, Key = TotalKey, Message = Encrypted
// Invoking to dekrypt
| invoke Dekrypt()
| project-reorder Result
| extend resultWords = split(Result, ' ')
| extend firstword = tostring(resultWords[1])
| summarize count(), take_any(Result) by firstword
| order by count_ desc 

range answer from 0 to 2147483647 step 1
| where bitset_count_ones(hash_many('kvcw8h26jm4hmdggn10nze', tostring(answer))) > 54
| project answer
| limit 1
```
