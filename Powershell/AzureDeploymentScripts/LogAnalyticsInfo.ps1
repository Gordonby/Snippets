param([string] $logAnalyticsName, [string] $resourceGroupName)
$output = 'Hello {0}' -f $logAnalyticsName
Write-Output $output
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['text'] = $output
