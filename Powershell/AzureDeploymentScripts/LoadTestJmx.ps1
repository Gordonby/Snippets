param([string] $loadtestname, [string] $resourcegroup, [string] $url)
$output = 'Hello {0}' -f $url
Write-Output $output

$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['text'] = $output
$DeploymentScriptOutputs['loadtest'] = $loadtestname
$DeploymentScriptOutputs['rg'] = $resourcegroup
