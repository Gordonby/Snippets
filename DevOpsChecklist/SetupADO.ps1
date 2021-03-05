$org="Barclays-DEV-LandingZone"
$proj="Barclays-Enterprise-Scale"

#Inspect environment security
$baseurl = "https://dev.azure.com/$org/$proj"

$url = "$baseurl/_environments/security"
 
Write-Output $url