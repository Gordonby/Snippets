$webappName = "WestEurope4"
$webappResourceGroup = "RegionalWebApps"

$appGwName = "AppGwForWebApps"
$appGwResourceGroup = "RegionalWebApps"

Login-AzureRmAccount

# Get the existing web app
$webapp = Get-AzureRmWebApp -ResourceGroupName $webappResourceGroup -Name $webappname
$ValidPoolWebAppHostName = $webapp.HostNames | ? {$_ -like "*.azurewebsites.net"}
$OtherWebAppHostNames = $webapp.HostNames | ? {$_ -notlike "*.azurewebsites.net"}

# Get the existing application gateway
$gw = Get-AzureRmApplicationGateway -Name $appGwName -ResourceGroupName $appGwResourceGroup

# Define the status codes to match for the probe
$match=New-AzureRmApplicationGatewayProbeHealthResponseMatch -StatusCode 200-399

# Add a new probe to the application gateway
Add-AzureRmApplicationGatewayProbeConfig -name "$($webappName)probe" -ApplicationGateway $gw -Protocol Http -Path / -Interval 30 -Timeout 120 -UnhealthyThreshold 3 -PickHostNameFromBackendHttpSettings -Match $match

# Retrieve the newly added probe
$probe = Get-AzureRmApplicationGatewayProbeConfig -name "$($webappName)probe" -ApplicationGateway $gw

# Add a new existing backend http settings 
Add-AzureRmApplicationGatewayBackendHttpSettings -Name "$($webappName)Settings" -ApplicationGateway $gw -PickHostNameFromBackendAddress -Port 80 -Protocol http -CookieBasedAffinity Disabled -RequestTimeout 30 -Probe $probe
$poolSetting = Get-AzureRmApplicationGatewayBackendHttpSettings -Name "$($webappName)Settings" -ApplicationGateway $gw

# Add the web app to the backend pool
Add-AzureRmApplicationGatewayBackendAddressPool -Name "$($webappName)Pool" -ApplicationGateway $gw -BackendFqdns $ValidPoolWebAppHostName
$pool = Get-AzureRmApplicationGatewayBackendAddressPool -Name "$($webappName)Pool" -ApplicationGateway $gw 

# Update the application gateway settings
# NB: We do this now as i've encountered exceptions in Adding a listener through Powershell.  
#     If it fails for you, then create the Listener and Rules manually in the Azure Portal UI.
Set-AzureRmApplicationGateway -ApplicationGateway $gw

#Lookup the FrontEnd settings
$frontEndConfig = Get-AzureRmApplicationGatewayFrontendIPConfig -applicationgateway $gw
$frontEndPort = Get-AzureRmApplicationGatewayFrontendPort -applicationgateway $gw | ? {$_.Port -eq 80}

#Configure the Http Listeners and rules for each domain.
$OtherWebAppHostNames | %{
    $listenerName=$_.replace(".","") + "Listener"
    $ruleName=$_.replace(".","") + "Rule"

    Add-AzureRmApplicationGatewayHttpListener -Name $listenerName -ApplicationGateway $gw -Protocol Http -frontendipconfiguration $frontEndConfig -frontendport $frontEndPort -hostname $_ 
    $listener = Get-AzureRmApplicationGatewayHttpListener -Name $listenerName -ApplicationGateway $gw

    Add-AzureRmApplicationGatewayRequestRoutingRule -Name $ruleName -ApplicationGateway $gw -RuleType Basic -BackendHttpSettings $poolSetting -HttpListener $listener -BackendAddressPool $pool 
}

# Update the application gateway
Set-AzureRmApplicationGateway -ApplicationGateway $gw



