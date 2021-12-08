$arm1filepath="main.json"
$arm2filepath="main2.json"

$arm1params = get-content $arm1filepath | ConvertFrom-Json -AsHashtable | Select -expandProperty parameters
$arm2params = get-content $arm2filepath | ConvertFrom-Json -AsHashtable | Select -expandProperty parameters

# $arm1hash = @{}
# $arm1paramList = @()
# $arm1params.keys | % { Write-Output $_; $param = New-Object PSObject -Property ([Ordered]@{Name=$_; DefaultValue=$arm1params.Get_Item($_).defaultValue }); $arm1paramList+= $param; $arm1hash.add($_, $arm1params.Get_Item($_).defaultValue) }

#powershell function to get the default value of a parameter

$arm1hash = @{}
$arm1paramList = @()
$arm1params.keys | % {
    Write-Output "--Processing $_";
    $val=$arm1params.Get_Item($_).defaultValue
    Write-Output "--Val $val";
    Write-Output $arm1params.Get_Item($_).type
    if( "int","string" -contains $arm1params.Get_Item($_).type) {
        $val=$arm1params.Get_Item($_).defaultValue
    } else {
        $val=$arm1params.Get_Item($_).defaultValue | ConvertTo-Json -Compress
    }
    $param = New-Object PSObject -Property ([Ordered]@{Name=$_; DefaultValue=$val });
    Write-Output $param
    $arm1paramList+= $param; $arm1hash.add($_, $arm1params.Get_Item($_).defaultValue)
}

$arm2hash = @{}
$arm2paramList = @()
$arm2params.keys | % {
    Write-Output "--Processing $_";
    $val=$arm2params.Get_Item($_).defaultValue
    Write-Output "--Val $val";
    Write-Output $arm2params.Get_Item($_).type
    if( "int","string" -contains $arm2params.Get_Item($_).type) {
        $val=$arm2params.Get_Item($_).defaultValue
    } else {
        $val=$arm2params.Get_Item($_).defaultValue | ConvertTo-Json -Compress
    }
    $param = New-Object PSObject -Property ([Ordered]@{Name=$_; DefaultValue=$val });
    Write-Output $param
    $arm2paramList+= $param; $arm2hash.add($_, $arm2params.Get_Item($_).defaultValue)
}


Compare-Object $arm1paramList $arm2paramList -Property Name, DefaultValue
