# DockerHub

Checking image sizes for popular DockerHub images.

> the contents of dockerHubSearchResponse.json is what the browser receives when using https://hub.docker.com/search

## Simplify the json

```bash
jq '.summaries[] | {imageName: .name, stars: .star_count}' dockerHubSearchResponse.json > topImages.json
```

```json
{
  "imageName": "datadog/agent",
  "stars": 98
}
{
  "imageName": "grafana/grafana",
  "stars": 2366
}...
```

## Doing it with pwsh

As much as i like jq, i'm stronger with pwsh than i am with bash for the rest of the script... So i'm abandoning bash, even though jq is miles better for working with json 😅

```powershell
$dockerResponse = Get-Content  dockerHubSearchResponse.json | ConvertFrom-Json
$dockerResponse | select-object -ExpandProperty summaries | select-object name, star_count | ConvertTo-Json | out-file topimages.json
```

## Augmenting the json with image size

```powershell
$topImages = Get-Content .\topimages.json | ConvertFrom-Json
$topImages | Add-Member -Name LatestTagSize -MemberType NoteProperty -Value 0

$topImages | ForEach-Object {
    $image = $_
    $tags = Invoke-RestMethod -Uri "https://hub.docker.com/v2/repositories/$($image.name)/tags/?page_size=100"
    $latestTag = $tags.results | Where-Object { $_.name -eq 'latest' }
    $compressedImageSize = $latestTag.full_size
    $compressedImageSizeMb = $compressedImageSize / 1024 / 1024
    
    $image.LatestTagSize = $compressedImageSizeMb
}

#sort by size
$topImages | Sort-Object -Property LatestTagSize -Descending

$topImages  | ConvertTo-Json | Out-File .\topimages2.json
```

## Measuring pull times

The datadog agent is the largest image size, so I'll use that for the testing.

### Locally

```powershell
measure-command {docker pull datadog/agent}
```

```
Days              : 0
Hours             : 0
Minutes           : 4
Seconds           : 7
Milliseconds      : 589
Ticks             : 2475897218
TotalDays         : 0.00286562178009259
TotalHours        : 0.0687749227222222
TotalMinutes      : 4.12649536333333
TotalSeconds      : 247.5897218
TotalMilliseconds : 247589.7218
```

### Results

Environment | Notes | Time taken
----------- | ----- | ----------
Local workstation | 40Mb/s download rate average | 4min 7s