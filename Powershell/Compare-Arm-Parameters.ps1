$arm1filepath="C:\Users\gobyers\Downloads\Aks-Construction-main (8)\Aks-Construction-main\bicep\compiled\main.json"
$arm2filepath="C:\ReposGitHub\Aks-Construction\bicep\compiled\main.json"

$arm1params = get-content $arm1filepath | ConvertFrom-Json -AsHashtable | Select -expandProperty parameters
$arm2params = get-content $arm2filepath | ConvertFrom-Json -AsHashtable | Select -expandProperty parameters

$hash = @{}
$arm1params.keys | % { echo $_; $hash.add($_, $arm1params.Get_Item($_).defaultValue) }

