# Azure DevOps - Enterprise Scale project onboarding [v0.8]
# Scripted version of the manual Azure DevOps instructions from https://github.com/Azure/Enterprise-Scale/blob/main/docs/Deploy/setup-azuredevops.md
# This script is optimised for a more complex Enterprise Scale bootstrap, using a Canary (dev) and Prod Top level bootstrap deployments.

# Prerequisites

# Recommendation is to run this from a BASH Azure CloudShell, Authenticated as a ADO Collection Administrator.
# The CloudShell is located: https://shell.azure.com

#Install AZ Devops Extension
az extension add -n azure-devops

#Need to explicitly login again in order for the azure-devops extension to work.
az login --use-device-code

#User provided variables, definitely change these
ADOORG="mscet"
ADOPROJ="CAE-AzOps-MultiEnv"
MGDEVNAME="canary"
MGPRODNAME="prod"

#Power variables, you can leave these as default
IMPORTREPO=1 #If you set this to 1, we'll import the ent-scale repo
MINAPPROVCOUNT=1
#REPONAME="EntScale"
ENTSCALEGITURL="https://github.com/Gordonby/AzOps-Accelerator"

#Internal variables - Don't tweak these.
ADOURL="https://dev.azure.com/$ADOORG/"


echo "Using $ADOURL"
az devops configure --defaults organization=$ADOURL

echo "Creating project $ADOPROJ"
az devops project create --name $ADOPROJ --process "Agile"

echo "Acquiring selected project $ADOPROJ"
PROJ=$(az devops project show -p $ADOPROJ)
echo $PROJ
az devops configure -d project=$ADOPROJ

#echo "Creating repo $REPONAME"
#az repos create --name $REPONAME
REPONAME=$ADOPROJ
REPOID=$(az repos show -r $REPONAME --query id -o tsv)

echo "Importing repo"
if (( $IMPORTREPO == 1 )); then
    az repos import create --git-source-url $ENTSCALEGITURL -r $REPONAME
else
    GITURL=$(az repos show -r $REPONAME --query remoteUrl -o tsv)
    git clone $GITURL
    cd $REPONAME
    mkdir ".azure-pipelines"
    cd ".azure-pipelines"
    mkdir "devplusprod"
    cd "devplusprod"
    curl -O https://raw.githubusercontent.com/Gordonby/Enterprise-Scale/main/.azure-pipelines/devplusprod/azops-pull.yml
    curl -O https://raw.githubusercontent.com/Gordonby/Enterprise-Scale/main/.azure-pipelines/devplusprod/azops-dev-push.yml
    curl -O https://raw.githubusercontent.com/Gordonby/Enterprise-Scale/main/.azure-pipelines/devplusprod/azops-prod-push.yml
    git add *
    git commit -m "Adding pipelines"
    git push 
fi

echo "Creating AzOps-Pull pipeline"
PIPEDEVPULL=$(az pipelines create --name 'AzOps-Dev-Pull' --description 'Pipeline for AzOps Pull' \
--repository $REPONAME --repository-type tfsgit --branch main --yml-path .pipelines//multienv/dev-pull.yml)
PIPEDEVPULLID=$(az pipelines show --name 'AzOps-Dev-Pull' --query "id" -o tsv)

PIPEDEVPUSH=$(az pipelines create --name 'AzOps-Dev-Push' --description 'Pipeline for AzOps Dev Push' \
--repository $REPONAME --repository-type tfsgit --branch main --yml-path .pipelines/multienv/dev-push.yml)
PIPEDEVPUSHID=$(az pipelines show --name 'AzOps-Dev-Push' --query "id" -o tsv)

echo "Creating Main branch policy - Approver Count"
az repos policy approver-count create --allow-downvotes true \
                                      --blocking true \
                                      --branch main \
                                      --creator-vote-counts false \
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
RANDOMUSERID=$(az devops user list --top 1 --query members[0].id -o tsv)
az repos policy required-reviewer create --blocking true \
                                         --branch main \
                                         --enabled true \
                                         --message "Changes to pipelines will need additional approval" \
                                         --repository-id $REPOID \
                                         --path-filter "/.pipelines/*" \
                                         --required-reviewer-ids $RANDOMUSERID

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
USERSTORYID=$(az boards work-item create --title "Ent-Scale Setup" --type 'User Story' --description "Manual tasks needed to complete ADO Enterprise-Scale setup" --query "id" -o tsv)
echo "USERSTORYID" $USERSTORYID
# 1. SPN variables set in the Pipelines
TASKID=$(az boards work-item create --title "Ent-Scale Setup : Set SPN Variables in Pipelines" --type 'Task' --description "3 Service Principal Credentials need to be created, and JSON representation added to the pipeline variables" --query "id" -o tsv)
echo $TASKID
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID
# 2. Permissions assigned for security groups.
TASKID=$(az boards work-item create --title "Set Project permissions" --type 'Task' --query "id" -o tsv)
echo $TASKID
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID
# 3. Environment approver for production
TASKID=$(az boards work-item create --title "Set Environment Approver for Production" --type 'Task' --query "id" -o tsv)
echo $TASKID
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID
# 4. Add the Build Service to the Project Contributors group
TASKID=$(az boards work-item create --title "Add Build Service to Project Contributors" --type 'Task' --query "id" -o tsv)
echo $TASKID
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID
# 5. Set pipeline folder required reviewer
TASKID=$(az boards work-item create --title "Change azure-pipelines required reviewer" --type 'Task' --query "id" -o tsv)
echo $TASKID
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID

sleep 30s
az boards work-item show --id $USERSTORYID --open
