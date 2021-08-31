$RG= 'ApimTest2'
$NameSeed= 'ApimAtt7'

az group create -n $RG -l WestEurope
#az deployment group what-if -f .\apim-internalvnet-publicip.bicep -g $RG -p nameSeed=$NameSeed
az deployment group create -f .\apim-internalvnet-publicip.bicep -g $RG -p nameSeed=$NameSeed publicIp=false
