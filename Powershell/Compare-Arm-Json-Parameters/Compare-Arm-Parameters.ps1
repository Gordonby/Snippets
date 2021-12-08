$arm1filepath="main.json"
$arm2filepath="main2.json"

$arm1params = get-content $arm1filepath | ConvertFrom-Json -AsHashtable | Select -expandProperty parameters
$arm2params = get-content $arm2filepath | ConvertFrom-Json -AsHashtable | Select -expandProperty parameters

$arm1paramList = @()
$arm1params.keys | % {
    $val=$arm1params.Get_Item($_).defaultValue
    if( "int","string" -contains $arm1params.Get_Item($_).type) {
        $val=$arm1params.Get_Item($_).defaultValue
    } else {
        $val=$arm1params.Get_Item($_).defaultValue | ConvertTo-Json -Compress
    }
    $arm1paramList += New-Object PSObject -Property ([Ordered]@{Name=$_; DefaultValue=$val });
}

$arm2paramList = @()
$arm2params.keys | % {
    $val=$arm2params.Get_Item($_).defaultValue
    if( "int","string" -contains $arm2params.Get_Item($_).type) {
        $val=$arm2params.Get_Item($_).defaultValue
    } else {
        $val=$arm2params.Get_Item($_).defaultValue | ConvertTo-Json -Compress
    }
    $arm2paramList+= New-Object PSObject -Property ([Ordered]@{Name=$_; DefaultValue=$val });
}

Compare-Object $arm1paramList $arm2paramList -Property Name, DefaultValue -PassThru | Sort-Object Name, SideIndicator | Format-Table -AutoSize
