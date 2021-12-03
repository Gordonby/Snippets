param([string] $logAnalyticsName, [string] $resourceGroupName)
$output = 'Hello {0}' -f $logAnalyticsName
Write-Output $output
$resource=Get-AzResource -Name $logAnalyticsName -ResourceGroupName $resourceGroupName
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['text'] = $output
$DeploymentScriptOutputs['loganalyticsname'] = $logAnalyticsName
$DeploymentScriptOutputs['rg'] = $resourceGroupName
$DeploymentScriptOutputs['resourceId'] = $resource.ResourceId
