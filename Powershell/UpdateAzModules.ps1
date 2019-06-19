#Azure Automation Accounts use Modules to provide code capability across all the Runbooks in an Automation Account
#The responsibility for keeping the Azure Modules up to date lies with the customer.
#The Automation Account does not directly facilitate the updating of the modules any longer.
#There is however a Runbook available to deploy into your Automation Account that can be run on a schedule to keep the Modules up to date
#The script below, places the Runbook in your Automation Account, but does not create the schedule
#If you want the to ensure the Runbook is also kept up to date, you can schedule this Powershell to run inside another runbook, on a schedule :)

$automationAccountName = ""
$automationAccountRgName = ""
$uriToUpdateRunbook="https://raw.githubusercontent.com/microsoft/AzureAutomation-Account-Modules-Update/master/Update-AutomationAzureModulesForAccount.ps1"
$pathToUpdateRunbook="Update-AutomationAzureModulesForAccount.ps1"

#Download the powershell runbook
Invoke-WebRequest -Uri $uriToUpdateRunbook -OutFile $pathToUpdateRunbook

#Re-import it
Import-AzAutomationRunbook -Name "AzureModuleUpdater" `
    -ResourceGroupName $automationAccountRgName `
    -AutomationAccountName $automationAccountName  `
    -Path $pathToUpdateRunbook `
    -Type PowerShell `
    -Force `
    -Published
