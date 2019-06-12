# Install the Resource Graph module from PowerShell Gallery
Install-Module -Name Az.ResourceGraph

# Connect to Azure
Connect-AzAccount

# Filter to the right subscriptions
$subscriptions = Get-AzSubscription | ? {$_.name -like "Contoso*"} | select Id, Name

# Create an on the fly CASE() statement in KQL of the subscriptionId -> Name mappings.
$subscriptionFilterTextArray=@()
$subscriptions | % {
    $subscriptionFilterTextArray += "    subscriptionId == '$($_.Id)', '$($_.Name)'"
}
$subscriptionExtendFilter = "extend SubscriptionName = case(`r`n" + [system.String]::Join(", `r`n", $subscriptionFilterTextArray) + ", subscriptionId)"

# Compose core query
$query="where type == 'microsoft.compute/virtualmachines' |
where tags !hasprefix 'orchestrator' | 
$subscriptionExtendFilter |
project subscriptionId, resourceGroup, name, properties.hardwareProfile.vmSize, properties.licenseType, tags"

# Run query
$results = Search-AzGraph -Query $query -Subscription $subscriptions

$results