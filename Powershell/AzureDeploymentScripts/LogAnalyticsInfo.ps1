param([string] $logAnalyticsName, [string] $resourceGroupName)
Write-Output "Searching for $logAnalyticsName in $resourceGroupName"
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['text'] = $logAnalyticsName
