
Function GetAzureADToken
{
    param(
        [String] $tenantId,
        [String] $clientId,
        [String] $clientSecret,
        [String] $resourceId = "https://graph.windows.net"
    )
    $oauth2tokenendpointv1 = "https://login.microsoftonline.com/$tenantId/oauth2/token"
    $scope = [System.Web.HttpUtility]::UrlEncode($resourceId)
    $encSecret = [System.Web.HttpUtility]::UrlEncode($clientSecret)
    $body = "grant_type=client_credentials&resource=$($scope)&client_id=$($clientId)&client_secret=$($encSecret)"
    $res = Invoke-WebRequest -Uri $oauth2tokenendpointv1 -Body $body -Method Post
    $authResult = $res.Content | ConvertFrom-Json
    return $authResult.access_token
}

Function GetMsGraphToken
{
    param(
        [String] $tenantId,
        [String] $clientId,
        [String] $clientSecret,
        [String] $scope = "https://graph.microsoft.com/.default"
    )
    $oauth2tokenendpointv2 = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $scope = [System.Web.HttpUtility]::UrlEncode($scope)
    $encSecret = [System.Web.HttpUtility]::UrlEncode($clientSecret)
    $body = "grant_type=client_credentials&scope=$($scope)&client_id=$($clientId)&client_secret=$($encSecret)"
    $res = Invoke-WebRequest -Uri $oauth2tokenendpointv2 -Body $body -Method Post
    $authResult = $res.Content | ConvertFrom-Json
    return $authResult.access_token
}
