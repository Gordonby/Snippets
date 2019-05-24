# Install the Resource Graph module from PowerShell Gallery
Install-Module -Name Az.ResourceGraph

# Connect to Azure
Connect-AzAccount

# Filter to the right subscriptions
$subscriptions = Get-AzSubscription | ? {$_.name -like "Contoso*"} | select  Id -ExpandProperty

# Compose query
$query="where type == 'microsoft.compute/virtualmachines' |
where tags.environment == 'dev' |
project subscriptionId, resourceGroup, name, properties.hardwareProfile.vmSize, properties.licenseType"

# Run query
Search-AzGraph -Query $query -Subscription $subscriptions