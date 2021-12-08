$arm1filepath="main.json"
$arm2filepath="main2.json"

$arm1params = get-content $arm1filepath | ConvertFrom-Json -AsHashtable | Select -expandProperty parameters
$arm2params = get-content $arm2filepath | ConvertFrom-Json -AsHashtable | Select -expandProperty parameters

$arm1paramList = @()
$arm1params.keys | % {
    $arm1paramList += New-Object PSObject -Property ([Ordered]@{Name=$_; DefaultValue=$arm1params.Get_Item($_).defaultValue | ConvertTo-Json -Compress });
}

$arm2paramList = @()
$arm2params.keys | % {
    $arm2paramList+= New-Object PSObject -Property ([Ordered]@{Name=$_; DefaultValue=$arm2params.Get_Item($_).defaultValue | ConvertTo-Json -Compress });
}

Compare-Object $arm1paramList $arm2paramList -Property Name, DefaultValue -PassThru | Sort-Object Name, SideIndicator | Format-Table -AutoSize
