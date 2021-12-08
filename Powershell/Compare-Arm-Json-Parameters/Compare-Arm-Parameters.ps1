$arm1params = get-content "main.json" | ConvertFrom-Json -AsHashtable | Select -expandProperty parameters
$arm2params = get-content "main2.json" | ConvertFrom-Json -AsHashtable | Select -expandProperty parameters

$arm1paramList = @()
$arm1params.keys | % {$arm1paramList += New-Object PSObject -Property ([Ordered]@{Name=$_; DefaultValue=$arm1params.Get_Item($_).defaultValue | ConvertTo-Json -Compress })}

$arm2paramList = @()
$arm2params.keys | % {$arm2paramList+= New-Object PSObject -Property ([Ordered]@{Name=$_; DefaultValue=$arm2params.Get_Item($_).defaultValue | ConvertTo-Json -Compress })}

$comparison = Compare-Object $arm1paramList $arm2paramList -Property Name, DefaultValue -PassThru | Sort-Object Name, SideIndicator

[string]$html = $comparison | ConvertTo-Html | Out-String
$html | Out-File "ghpr.html"

if ($comparison.length -gt 0) {
    #$markdownTableHeader = '|{0}|' -f (($comparison[0].PSObject.Properties.Name -replace '(?<!\\)\|', '\|') -join '|') + '|{0}|' -f (($comparison[0].PSObject.Properties.Name -replace '.', '-') -join '|')
    #$markdownTableBody= $comparison | % {'|{0}|' -f (($_.PsObject.Properties.Value -replace '(?<!\\)\|', '\|') -join '|')}
    #[string]$markdown= $markdownTableHeader + $markdownTableBody
    #gh pr comment 3 -b $html

    #Why do markdown, when you can do HTML :D

    gh pr comment 3 -F "ghpr.html"
}