$ResourceGroupName = "SpotTest"
$VmName="MySpotVm"
$AdminPassword="ARe@11y5ecur3P@ssw0rd!"
$Location="WestEurope"

az group create --name $ResourceGroupName --location $Location
az vm create -g $ResourceGroupName -n $VmName --image UbuntuLTS --admin-username azureuser --admin-password $AdminPassword --generate-ssh-keys --priority spot --size Standard_A1

az vm show -g $ResourceGroupName -n $VmName --query "[priority,provisioningState]"

az vm simulate-eviction -g $ResourceGroupName -n $VmName

az vm show -g $ResourceGroupName -n $VmName --query "[priority,provisioningState]"

