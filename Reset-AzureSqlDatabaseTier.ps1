#gordon.byers@microsoft.com
#Powershell script is provided as-is and without any warranty of any kind

#Login to Azure
Login-AzureRmAccount

#Iterate through all databases in the Subscription where Editon is not basic.
$desiredDbTier = "Basic"
Get-AzureRmResourceGroup | % {Get-AzureRmSqlServer -ResourceGroupName $_.ResourceGroupName | % {Get-AzureRmSqlDatabase -ServerName $_.Servername -ResourceGroupName $_.ResourceGroupName | ? {$_.CurrentServiceObjectiveName -ne "System" -and $_.CurrentServiceObjectiveName -ne $desiredDbTier -and $_.DatabaseName -ne "Master" } | Set-AzureRmSqlDatabase -Edition $desiredDbTier }}
