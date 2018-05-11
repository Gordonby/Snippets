#
# Ref : https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-external-users


param(
    $subscriptionName="Visual Studio Enterprise"
    #$resourcegroup="fambackups"
)


Clear-AzureRmContext -Scope Process

Connect-AzureRmAccount
$sub = Select-AzureRmSubscription -Subscription $subscriptionName

$request = Invoke-WebRequest "https://raw.githubusercontent.com/Gordonby/Snippets/master/Powershell/Nsg-UpdateRules-OnLocalIpChange/NsgCustomRole.json"
$customRole = $request | ConvertFrom-Json

#Correct the tokens in the Github json file with real values
$customRole.AssignableScopes[0] = $customRole.AssignableScopes[0].Replace("your-subscription-id",$sub.subscription.Id) #.Replace("yourresourcegroup",$resourcegroup)

#See if the role already exists
$existingRole = Get-AzureRmRoleDefinition $customRole.Name

$customRoleFilePath = "C:\temp\nsg-custom-role.json"
if ($existingRole -eq $null) {
    $customRole | ConvertTo-Json | Out-File $customRoleFilePath
    New-AzureRmRoleDefinition -InputFile $customRoleFilePath
}
else {
    $customRole | Add-Member -MemberType NoteProperty -Name Id -Value $existingRole.Id
    $customRole | ConvertTo-Json | Out-File $customRoleFilePath
    Set-AzureRmRoleDefinition -InputFile $customRoleFilePath
}
