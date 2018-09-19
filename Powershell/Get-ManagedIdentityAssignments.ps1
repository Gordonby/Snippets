#Gordon.byers@microsoft.com
#Powershell script is provided as-is and without any warranty of any kind

$subscriptionId = ""

#See Verbose messages, if you like.
#$VerbosePreference = "continue"

#Connect to the right Azure subscription
Connect-AzureRmAccount
Select-AzureRmSubscription -subscriptionId $subscriptionId

#An array of keyvault strings to search.  You can be explicit about the Vault if you don't want to search all of them
$KeyVaults = Get-AzureRmKeyVault | Select-Object  -ExpandProperty VaultName
#$KeyVaults = "msidemo"
#$KeyVaults = @("msidemo", "NeVault")

#Get all the WebApps used in the subscription which use Managed Identity
$WebApps = Get-AzureRmWebApp
$webAppsWithMI = $WebApps | ? {$_.Identity.Type -eq 'SystemAssigned'}

$RbacSummary = @()
$kvSummary = @()

$webAppsWithMI | foreach-object {
    $WebAppName = $_.Name
    $PrincipalId = $_.Identity.PrincipalId

    Write-Verbose "Investigating Managed Identity on $WebAppName"

    Write-Verbose "Searching for $PrincipalId across Azure Resources in Subscription"
    $RbacAssignments = Get-AzureRmRoleAssignment -ObjectId $PrincipalId
    $RbacSummary += $RbacAssignments | Select-Object RoleDefinitionName, Scope | %{ Add-Member -inputObject $_ -passThru -type NoteProperty -name WebApp -Value $WebAppName}

    Write-Verbose "Searching for Key Vault assignments"
    $KeyVaults | % { 
        Write-Verbose "Searching access policies in Key Vault : $_"
        $kv = Get-AzureRmKeyVault -VaultName $_

        $AccessPoliciesForMI = $kv.AccessPolicies | ? {$_.ObjectId -eq $PrincipalId} | Select-Object PermissionsToSecretsStr, PermissionsToCertificatesStr | %{ Add-Member -inputObject $_ -passThru -type NoteProperty -name WebApp -Value $WebAppName} | %{ Add-Member -inputObject $_ -passThru -type NoteProperty -name KeyVault -Value $kv.VaultName}

        $kvSummary += $AccessPoliciesForMI
    }
}

Write-Output $RbacSummary | Select-Object WebApp, RoleDefinitionName, Scope;
Write-Output $kvSummary | Select-Object WebApp, KeyVault, PermissionsToSecretsStr, PermissionsToCertificatesStr;
