cd C:\ReposGitHub\Snippets\Hue

$hueBridgeLocalIpAddress="192.168.1.64"

$baseUrl="http://$hueBridgeLocalIpAddress"

#This is how you get to the simple Hue Bridge API interface
$clipApiToolUrl="$baseUrl/debug/clip.html"
Start-Process $clipApiToolUrl

#Register a new local API user. You'll need to push the button on the bridge before sending the request
$apiBaseUrl="$baseUrl/api"

#output the username to file

#Add the local API user to the url string
$apiUser = get-content localBridge.json | ConvertFrom-Json | Select-Object -ExpandProperty bridgeUser

#This is how you turn a light on
$bodyLightOn = '{"on":true}'
$lightNumber=1
$authApiUrl="$apiBaseUrl/$apiUser/lights/$lightNumber/state/"
Invoke-RestMethod -Method PUT -Uri $authApiUrl -ContentType "application/json" -Body $bodyLightOn;

#This is how you turn the light up to 100% brightness
$bodyLightOn = '{"on":true,"bri":254}'
$lightNumber=1
$authApiUrl="$apiBaseUrl/$apiUser/lights/$lightNumber/state/"
Invoke-RestMethod -Method PUT -Uri $authApiUrl -ContentType "application/json" -Body $bodyLightOn;