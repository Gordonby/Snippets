# Install the Resource Graph module from PowerShell Gallery
Install-Module -Name Az.ResourceGraph

# Connect to Azure
Connect-AzAccount

# Filter to the right subscriptions
$subscriptions = Get-AzSubscription | ? {$_.name -like "Contoso*"} | select -ExpandProperty Id 

# Compose query
$query="where type == 'microsoft.compute/virtualmachines' |
where tags !hasprefix 'orchestrator' |
project subscriptionId, resourceGroup, name, properties.hardwareProfile.vmSize, properties.licenseType, tags"

# Run query
$results = Search-AzGraph -Query $query -Subscription $subscriptions

$results