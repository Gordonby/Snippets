# Iana Time Region

Iana time regions are used in several Azure services in areas that pertain to time schedules.

Where there is a gap is relating Azure regions themselves to time schedules.

## Generating the azure region json

```bash
az account list-locations --query "[].{name:name, lat:metadata.latitude, long:metadata.longitude, geo:metadata.geographyGroup}" -o json > azure-regions.json
```

```powershell
Get-AzLocation | Where-Object Longitude -ne $null | Select-Object -property @{N='name';E={$_.Location}}, @{N='long';E={$_.Longitude}}, @{N='lat';E={$_.Latitude}} | ConvertTo-Json | Out-File azure-regions.json
```

## Enriching with TimeZones

I'll use timeapi to enrich the json file with the Iana time zone

```powershell
$regions = Get-Content ./azure-regions.json | ConvertFrom-Json | Add-Member -PassThru -type NoteProperty -name timeZone -value ""
$regions | % {$url="https://timeapi.io/api/TimeZone/coordinate?latitude=$($_.lat)&longitude=$($_.long)"; write-verbose $url; $time=$(Invoke-WebRequest $url).Content; $timeZone= $time | ConvertFrom-Json | Select-Object -ExpandProperty timeZone; $_.timeZone=$timeZone} | ConvertTo-Json | Out-File azure-regions-timezones.json
$regions | Select-Object name, timeZone | ConvertTo-Json | Out-File azure-regions-timezones.json
```

I also want the Json in a custom format, which would be easy in Bash with JQ, but in PowerShell is a bit more dirty

```powershell
$jsonHack = $regions | % { Write-Output """$($_.name)"" : ""$($_.timeZone)"""  } | Join-String -Separator ','
"{$($jsonHack)}" | Out-File ./azure-region-lookup.json
```
