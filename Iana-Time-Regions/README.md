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

## Enriching the file from 

