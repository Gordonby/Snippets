$topImages = Get-Content .\topimages.json | ConvertFrom-Json
$topImages | Add-Member -TypeName integer -Name LatestTagSize -MemberType NoteProperty -Value 0

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