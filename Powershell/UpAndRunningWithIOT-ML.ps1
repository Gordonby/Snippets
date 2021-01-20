

cd C:\ReposGitHub\ #CD to whatever your preferred local dir is
$adminPw = ConvertTo-SecureString -String "y0urpa%%worD" -AsPlainText -Force

#Change subscription if needed
#Set-AzContext -Subscription 'gobyers-int'

#clone repo
git clone https://github.com/Azure-Samples/IoTEdgeAndMlSample.git
Set-ExecutionPolicy Bypass -Scope Process -Force
cd IoTEdgeAndMlSample


$subId = (Get-AzContext).Subscription.id

#Run the Create Dev VM script.  It uses the AzureRM cmdlets, but it does this through the AZ module alias capability
cd DevVM
.\Create-AzureDevVm-Better.ps1 -SubscriptionId $subId -ResourceGroupName "IoTandMLSample" -Location 'West Europe' -AdminUsername admingeneric -AdminPassword $adminPw



