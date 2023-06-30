# Azure DevOps - Enterprise Scale project onboarding [v0.5]
# Scripted version of the manual Azure DevOps instructions from https://github.com/Azure/Enterprise-Scale/blob/main/docs/Deploy/setup-azuredevops.md
# This script is optimised for a more complex Enterprise Scale bootstrap, using a Canary (dev) and Prod Top level bootstrap deployments.

#Recommendation is to run this from a BASH Azure CloudShell, Authenticated as a ADO Collection Administrator.
#The CloudShell is located: https://shell.azure.com

#Install AZ Devops Extension
az extension add -n azure-devops

#Need to explicitly login again in order for the azure-devops extension to work.
az login --use-device-code

#User provided variables, definitely change these
ADOORG="gdoggmsft"
ADOPROJ="Enterprise-Scale"

#Internal variables - Don't tweak these.
ADOURL="https://dev.azure.com/$ADOORG/"

echo "Using $ADOURL"
az devops configure --defaults organization=$ADOURL

echo "Using project $ADOPROJ"
az devops configure -d project=$ADOPROJ

#Work still to be done.
USERSTORYID=$(az boards work-item create --title "Secure Azure DevOps" --type 'User Story' --description "Manual tasks needed to complete ADO secure configuration" --query "id" -o tsv)
echo "USERSTORYID" $USERSTORYID

TASKID=$(az boards work-item create --title "Configure parallel jobs" --type 'Task' --description "At least one parallel pipeline job is required to for the Azure DevOps SLA to apply." --query "id" -o tsv)
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID

TASKID=$(az boards work-item create --title "Restrict organisation creation" --type 'Task' --query "id" -o tsv)
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID

TASKID=$(az boards work-item create --title "Enable AzureAD conditional access for ADO logins" --type 'Task' --query "id" -o tsv)
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID

TASKID=$(az boards work-item create --title "Disable Guest Access to ADO" --type 'Task' --query "id" -o tsv)
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID

sleep 30s
az boards work-item show --id $USERSTORYID --open
