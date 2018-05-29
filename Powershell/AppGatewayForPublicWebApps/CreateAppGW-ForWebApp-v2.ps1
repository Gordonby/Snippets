#Gordon.byers@microsoft.com
#Powershell script is provided as-is and without any warranty of any kind

#Creates a new Azure Application Gateway for an existing Web App.
#Will optionally create multi-site listeners if the web app has custom domains configured

$webappname = "westeurope3g"
$resourcegroupname = "RegionalWebApps"
$resourcegrouplocation = "WestEurope"
$appgatewayName = "AppGwForWebApps"

Login-AzureRmAccount

# Gets the resource group with the web app in it.
$rg = Get-AzureRmResourceGroup -Name $resourcegroupname -Location $resourcegrouplocation

# Get the web app
$webapp = Get-AzureRmWebApp -ResourceGroupName $rg.ResourceGroupName -Name $webappname
$ValidPoolWebAppHostNames = $webapp.HostNames | ? {$_ -like "*.azurewebsites.net"}
$OtherWebAppHostNames = $webapp.HostNames | ? {$_ -notlike "*.azurewebsites.net"}

# Creates network gubbins
$subnet = New-AzureRmVirtualNetworkSubnetConfig -Name "subnet$appgatewayName" -AddressPrefix 10.0.0.0/27
$vnet = New-AzureRmVirtualNetwork -Name "vnet$appgatewayName" -ResourceGroupName $rg.ResourceGroupName -Location $rg.location -AddressPrefix 10.0.0.0/24 -Subnet $subnet
$subnet=$vnet.Subnets[0]

# Create a public IP address
$publicip = New-AzureRmPublicIpAddress -ResourceGroupName $rg.ResourceGroupName -name "pip$appgatewayName" -location $rg.location -AllocationMethod Dynamic

# Create a new IP configuration
$gipconfig = New-AzureRmApplicationGatewayIPConfiguration -Name gatewayIP01 -Subnet $subnet

# Create a backend pool with the hostname of the web app
$pool = New-AzureRmApplicationGatewayBackendAddressPool -Name "$($webappname)Pool" -BackendFqdns $ValidPoolWebAppHostNames

# Define the status codes to match for the probe
$match = New-AzureRmApplicationGatewayProbeHealthResponseMatch -StatusCode 200-399

# Create a probe with the PickHostNameFromBackendHttpSettings switch for web apps
$probeconfig = New-AzureRmApplicationGatewayProbeConfig -name "$($webappname)Probe" -Protocol Http -Path / -Interval 30 -Timeout 120 -UnhealthyThreshold 3 -PickHostNameFromBackendHttpSettings -Match $match

# Define the backend http settings
$poolSetting = New-AzureRmApplicationGatewayBackendHttpSettings -Name "$($webappname)Settings" -Port 80 -Protocol Http -CookieBasedAffinity Disabled -RequestTimeout 120 -PickHostNameFromBackendAddress -Probe $probeconfig

# Create a new front-end port
$fp = New-AzureRmApplicationGatewayFrontendPort -Name frontendport01  -Port 80

# Create a new front end IP configuration
$fipconfig = New-AzureRmApplicationGatewayFrontendIPConfig -Name fipconfig01 -PublicIPAddress $publicip

# Create a new listener using the front-end ip configuration and port created earlier
if ($OtherWebAppHostNames -eq $null) {
    $listener = New-AzureRmApplicationGatewayHttpListener -Name listener01 -Protocol Http -FrontendIPConfiguration $fipconfig -FrontendPort $fp
}
else {
    $listener = New-AzureRmApplicationGatewayHttpListener -Name "$($webappname)Listener" -Protocol Http -FrontendIPConfiguration $fipconfig -FrontendPort $fp -HostName $OtherWebAppHostNames
}
# Create a new rule
$rule = New-AzureRmApplicationGatewayRequestRoutingRule -Name "$($webappname)Rule" -RuleType Basic -BackendHttpSettings $poolSetting -HttpListener $listener -BackendAddressPool $pool 

# Define the application gateway SKU to use
$sku = New-AzureRmApplicationGatewaySku -Name Standard_Small -Tier Standard -Capacity 2

# Create the application gateway
$appgw = New-AzureRmApplicationGateway -Name $appgatewayName -ResourceGroupName $rg.ResourceGroupName -Location $rg.location -BackendAddressPools $pool -BackendHttpSettingsCollection $poolSetting -Probes $probeconfig -FrontendIpConfigurations $fipconfig  -GatewayIpConfigurations $gipconfig -FrontendPorts $fp -HttpListeners $listener -RequestRoutingRules $rule -Sku $sku
