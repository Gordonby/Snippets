param([string] $logAnalyticsName)
$output = 'Searching for {0}' -f $logAnalyticsName
Write-Output $output
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['text'] = $output
