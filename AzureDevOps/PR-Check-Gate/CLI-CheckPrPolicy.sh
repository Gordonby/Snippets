#https://docs.microsoft.com/en-us/cli/azure/repos/pr/policy?view=azure-cli-latest

PRPolicy=$(az repos pr policy list --id 43 --query "[].{ApproveStatus:status, Policy:configuration.type.displayName, IsBlocking:configuration.isBlocking}" -o json)
echo $PRPolicy | jq -r '.[] | select(.IsBlocking==true) | select(.ApproveStatus != "approved")'
echo $PRPolicy | jq -r