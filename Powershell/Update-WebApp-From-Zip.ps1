#Gordon.byers@microsoft.com
#Powershell script is provided as-is and without any warranty of any kind

$sitename="myappservicesite"
$username = "myappservicedeployuid"
$password = "myappservicedeploypw"
$filePath = "C:\Temp\MyBlog\simply-static-1-1529530054.zip"

Write-Verbose "Convert username and password to base64"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))

#Upload zip file to update webapp
$apiUrl = "https://$sitename.scm.azurewebsites.net/api/zip/site/wwwroot"
Invoke-RestMethod -Uri $apiUrl -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method PUT -InFile $filePath -ContentType "multipart/form-data" | Out-Null
