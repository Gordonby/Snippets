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
