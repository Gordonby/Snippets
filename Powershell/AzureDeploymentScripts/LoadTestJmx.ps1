param([string] $LoadTestResourceName, [string] $ResourceGroup, [string] $TestName, [string] $TestUrl, [string] $JmxBaseFileUrl, [string] $TestMethod="Get")
$debug = 'Hello {0}' -f $TestUrl
Write-Output $output
Write-Output "Getting Base Jmeter XML"
Write-Output "Injecting URL into XML"
Write-Output "Persisting Jmeter XML file to local runspace"
Write-Output "Adding new Test $TestName to $LoadTestResourceName"
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['debug'] = $debug
$DeploymentScriptOutputs['loadtest'] = $LoadTestResourceName
$DeploymentScriptOutputs['rg'] = $ResourceGroup
$DeploymentScriptOutputs['method'] = $TestMethod
$DeploymentScriptOutputs['testurl'] = $TestUrl
