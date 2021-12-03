param([string] $loadtestname, [string] $resourcegroup, [string] $url)
$output = 'Hello {0}' -f $url
Write-Output $output
Write-Output "Getting Base Jmeter XML"
Write-Output "Injecting URL into XML"
Write-Output "Persisting Jmeter XML file to local runspace"
Write-Output "Adding new Test"
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['text'] = $output
$DeploymentScriptOutputs['loadtest'] = $loadtestname
$DeploymentScriptOutputs['rg'] = $resourcegroup
