param([string] $logAnalyticsName, [string] $resourceGroupName)
Write-Output "Searching for $logAnalyticsName in $resourceGroupName"
$resource=Get-AzResource -Name $logAnalyticsName -ResourceGroupName $resourceGroupName
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['text'] = $resource.ResourceId
