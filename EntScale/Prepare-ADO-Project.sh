# Azure DevOps - Enterprise Scale project onboarding [v0.3]
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
ADOPROJ="EntScaleTwoOh"
MGDEVNAME="dev"
MGPRODNAME="prod"
APPROVPIPELINE="gobyers@microsoft.com" #Used to protect the /.azure-pipelines/ directory with an explict approver


#Power variables, you can leave these as default
IMPORTREPO=1 #If you set this to 1, we'll import the ent-scale repo
MINAPPROVCOUNT=1
REPONAME="EntScale"
ENTSCALEGITURL="https://github.com/Gordonby/Enterprise-Scale.git"

#Internal variables - Don't tweak these.
ADOURL="https://dev.azure.com/$ADOORG/"

echo "Using $ADOURL"
az devops configure --defaults organization=$ADOURL

echo "Creating project $ADOPROJ"
az devops project create --name $ADOPROJ

echo "Acquiring selected project $ADOPROJ"
PROJ=$(az devops project show -p $ADOPROJ)
echo $PROJ
az devops configure -d project=$ADOPROJ

echo "Creating repo $REPONAME"
az repos create --name $REPONAME
REPOID=$(az repos show -r $REPONAME --query id -o tsv)

echo "Importing repo"
if [$IMPORTREPO==1]
then
    az repos import create --git-source-url $ENTSCALEGITURL -r $REPONAME
else
    az repos create -r $REPONAME

    #TODO:Need to manually push the 3 pipeline files
fi

echo "Creating AzOps-Pull pipeline"
PIPEPULL=$(az pipelines create --name 'AzOps-Pull' --description 'Pipeline for AzOps Pull' \
--repository $REPONAME --repository-type tfsgit --branch main --yml-path .azure-pipelines/devplusprod/azops-pull.yml)

PIPEDEVPUSH=$(az pipelines create --name 'AzOps-Dev-Push' --description 'Pipeline for AzOps Dev Push' \
--repository $REPONAME --repository-type tfsgit --branch main --yml-path .azure-pipelines/devplusprod/azops-dev-push.yml)
PIPEDEVPUSHID=$(az pipelines show --name 'AzOps-Dev-Push' --query "id" -o tsv)

PIPEPRODPUSH=$(az pipelines create --name 'AzOps-Prod-Push' --description 'Pipeline for AzOps Prod Push' \
--repository $REPONAME --repository-type tfsgit --branch main --yml-path .azure-pipelines/devplusprod/azops-prod-push.yml)
PIPEPRODPUSHID=$(az pipelines show --name 'AzOps-Prod-Push' --query "id" -o tsv)

echo "Creating pipeline variables"
az pipelines variable create --name REPOPATH \
                             --detect true \
                             --pipeline-id $PIPEDEVPUSHID \
                             --value $MGDEVNAME

az pipelines variable create --name REPOPATH \
                             --detect true \
                             --pipeline-id $PIPEPRODPUSHID \
                             --value $MGPRODNAME

echo "Creating Main branch policy - Approver Count"
az repos policy approver-count create --allow-downvotes true \
                                      --blocking true \
                                      --branch main \
                                      --creator-vote-counts true \
                                      --enabled true \
                                      --minimum-approver-count $MINAPPROVCOUNT \
                                      --repository-id $REPOID \
                                      --reset-on-source-push true

echo "Creating Main branch policy - Work Item warning"
az repos policy work-item-linking create --blocking false \
                                         --branch main \
                                         --enabled true \
                                         --repository-id $REPOID

echo "Creating Main branch policy - Comment Resolution warning"
az repos policy comment-required create --blocking false \
                                        --branch main \
                                        --enabled true \
                                        --repository-id $REPOID

echo "Createing Main branch policy - Merging"
az repos policy merge-strategy create --blocking true \
                                      --branch main \
                                      --enabled true \
                                      --repository-id $REPOID \
                                      --allow-no-fast-forward false \
                                      --allow-rebase false \
                                      --allow-rebase-merge false \
                                      --allow-squash true

echo "Creating Main branch policy - Pipeline Approvers"
az repos policy required-reviewer create --blocking true \
                                         --branch main \
                                         --enabled true \
                                         --message "Changes to pipelines will need additional approval" \
                                         --repository-id $REPOID \
                                         --path-filter "/.azure-pipelines/" \
                                         --required-reviewer-ids $APPROVPIPELINE


echo "Creating Main branch build policy - AzOps Dev Push"
az repos policy build create --blocking true \
                             --branch main \
                             --build-definition-id $PIPEDEVPUSHID \
                             --display-name "AzOpsDevPush" \
                             --enabled true \
                             --manual-queue-only false \
                             --queue-on-source-update-only true \
                             --repository-id $REPOID \
                             --path-filter "/azops/$MGDEVNAME ($MGDEVNAME)/*" \
                             --valid-duration 720

echo "Creating Main branch build policy - AzOps Prod Push"
az repos policy build create --blocking true \
                             --branch main \
                             --build-definition-id $PIPEPRODPUSHID \
                             --display-name "AzOpsProdPush" \
                             --enabled true \
                             --manual-queue-only false \
                             --queue-on-source-update-only true \
                             --repository-id $REPOID \
                             --path-filter "/azops/$MGPRODNAME ($MGPRODNAME)/*" \
                             --valid-duration 720


#Work still to be done.
# 1. SPN variables set in the Pipelines
# 2. Permissions assigned for security groups.
# 3. Environment approver for production
# 4. Add the Build Service to the Project Contributors group