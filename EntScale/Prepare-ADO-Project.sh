# Azure DevOps - Enterprise Scale project onboarding [v0.93]
# Scripted version of the manual Azure DevOps instructions from https://github.com/Azure/Enterprise-Scale/blob/main/docs/Deploy/setup-azuredevops.md
# This script is optimised for a more complex Enterprise Scale bootstrap, using a Canary (dev) and Prod Top level bootstrap deployments.
# To see the running implementation : https://dev.azure.com/mscet/CAE-AzOps-MultiEnv/_git/CAE-AzOps-MultiEnv
# Also refer to the Readme : https://github.com/Azure/AzOps-Accelerator/tree/main/.pipelines/samples#multi-environment

# Recommendation is to run this from a BASH Azure CloudShell, Authenticated as a ADO Collection Administrator. Although, WSL/Linux is also suitable.
# The CloudShell is located: https://shell.azure.com

#TODO, to get to v1.0
# AzOps to work with Dynamictree
# Replace in the repo the name of the MG's MGPRODNAME in the JSON settings, and the folder path of the respective pipelines
# [done] Remove the subscriptionId from the Multi-env AzLoginSp yaml


#Install AZ Devops Extension
az extension add -n azure-devops

#Need to explicitly login AGAIN in order for the azure-devops extension to work.
az login --use-device-code

#User provided variables, definitely change these
ADOORG="gdoggmsft"
ADOPROJ="EntScaleT9"
MGDEVNAME="canary"
MGPRODNAME="prod"

#Power variables, you can leave these as default
IMPORTREPO=0 #If you set this to 1, we'll import the ent-scale repo
MINAPPROVCOUNT=1
ENTSCALEGITURL="https://github.com/Azure/AzOps-Accelerator.git"
ENTSCALEGITBRANCH=""


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
    echo "Cloning from $ENTSCALEGITURL $ENTSCALEGITBRANCH to temp dir"
    if (( $ENTSCALEGITBRANCH == '' )); then
        echo "Cloning main branch from repo"
        git clone $ENTSCALEGITURL temp/acceleratorrepo
    else
        echo "Cloning $ENTSCALEGITBRANCH branch from repo"
        git clone -b $ENTSCALEGITBRANCH $ENTSCALEGITURL temp/acceleratorrepo
    fi

    GITURL=$(az repos show -r $REPONAME --query remoteUrl -o tsv)
    echo "Cloning from  $GITURL"
    echo "You'll need to get a GIT PAT token from https://dev.azure.com/$ADOORG/_git/$ADOPROJ - Click 'Generate Git Credentials' and paste the credentials when prompted"
    
    git clone $GITURL
    cd $REPONAME

    git checkout -b main

    cp ../temp/acceleratorrepo/.pipelines/samples/Multiple-Environment/*.json .

    mkdir ".pipelines"

    cp ../temp/acceleratorrepo/.pipelines/samples/Multiple-Environment/templates .pipelines/ -r
    cp ../temp/acceleratorrepo/.pipelines/samples/Multiple-Environment/multienv .pipelines/ -r

    git add *
    git add .pipelines/*
    git commit -m "Adding pipeline files"

    git push --set-upstream origin main

    az repos update -r $REPONAME --default-branch main
fi

echo "Creating AzOps-Pull pipeline"
PIPEDEVPULL=$(az pipelines create --name 'AzOps-Canary-Pull' --description 'Pipeline for AzOps Canary Pull' \
--repository $REPONAME --repository-type tfsgit --branch main --yml-path .pipelines/multienv/canary-pull.yml)
PIPEDEVPULLID=$(az pipelines show --name 'AzOps-Canary-Pull' --query "id" -o tsv)

PIPEDEVPUSH=$(az pipelines create --name 'AzOps-Canary-Push' --description 'Pipeline for AzOps Canary Push' \
--repository $REPONAME --repository-type tfsgit --branch main --yml-path .pipelines/multienv/canary-push.yml)
PIPEDEVPUSHID=$(az pipelines show --name 'AzOps-Canary-Push' --query "id" -o tsv)

PIPEDEVVALIDATE=$(az pipelines create --name 'AzOps-Canary-Validate' --description 'Pipeline for AzOps Canary Validate' \
--repository $REPONAME --repository-type tfsgit --branch main --yml-path .pipelines/multienv/canary-validate.yml)
PIPEDEVVALIDATEID=$(az pipelines show --name 'AzOps-Canary-Validate' --query "id" -o tsv)


echo "Creating AzOps-Pull pipeline"
PIPEPRODPULL=$(az pipelines create --name 'AzOps-Prod-Pull' --description 'Pipeline for AzOps Prod Pull' \
--repository $REPONAME --repository-type tfsgit --branch main --yml-path .pipelines/multienv/prod-pull.yml)
PIPEPRODPULLID=$(az pipelines show --name 'AzOps-Prod-Pull' --query "id" -o tsv)

PIPEPRODPUSH=$(az pipelines create --name 'AzOps-Prod-Push' --description 'Pipeline for AzOps Prod Push' \
--repository $REPONAME --repository-type tfsgit --branch main --yml-path .pipelines/multienv/prod-push.yml)
PIPEPRODPUSHID=$(az pipelines show --name 'AzOps-Prod-Push' --query "id" -o tsv)

PIPEPRODVALIDATE=$(az pipelines create --name 'AzOps-Prod-Validate' --description 'Pipeline for AzOps Prod Validate' \
--repository $REPONAME --repository-type tfsgit --branch main --yml-path .pipelines/multienv/prod-validate.yml)
PIPEPRODVALIDATEID=$(az pipelines show --name 'AzOps-Prod-Validate' --query "id" -o tsv)


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

echo "Creating Main branch build policy - AzOps Canary Push"
az repos policy build create --blocking true \
                             --branch main \
                             --build-definition-id $PIPEDEVVALIDATEID \
                             --display-name "AzOpsCanaryValidate" \
                             --enabled true \
                             --manual-queue-only false \
                             --queue-on-source-update-only true \
                             --repository-id $REPOID \
                             --path-filter "/azops-$MGDEVNAME/$MGDEVNAME ($MGDEVNAME)/*" \
                             --valid-duration 720

echo "Creating Main branch build policy - AzOps Prod Push"
az repos policy build create --blocking true \
                             --branch main \
                             --build-definition-id $PIPEPRODVALIDATEID \
                             --display-name "AzOpsProdValidate" \
                             --enabled true \
                             --manual-queue-only false \
                             --queue-on-source-update-only true \
                             --repository-id $REPOID \
                             --path-filter "/azops-$MGPRODNAME/$MGPRODNAME ($MGPRODNAME)/*" \
                             --valid-duration 720


#Work still to be done.
USERSTORYID=$(az boards work-item create --title "Ent-Scale Setup" --type 'User Story' --description "Manual tasks needed to complete ADO Enterprise-Scale setup" --query "id" -o tsv)
echo "USERSTORYID" $USERSTORYID
# 1. SPN variables set in the Pipelines
TASKID=$(az boards work-item create --title "Ent-Scale Setup : Set AzOps SPN Variable group in Pipelines" --type 'Task' --description "3 Service Principal Credentials need to be created, and JSON representation added to the pipeline variables" --query "id" -o tsv)
echo $TASKID
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID
# 2. Permissions assigned for security groups.
TASKID=$(az boards work-item create --title "Setup any AzureAD - ADO security group permissions" --type 'Task' --query "id" -o tsv)
echo $TASKID
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID
# 3. Environment approver for production
TASKID=$(az boards work-item create --title "Setup Environment Approver for Production" --type 'Task' --query "id" -o tsv)
echo $TASKID
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID
# 3b. Environment approver for production
TASKID=$(az boards work-item create --title "Setup Environment Approver for Canary" --type 'Task' --query "id" -o tsv)
echo $TASKID
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID
# 4. Add the Build Service to the Project Contributors group
TASKID=$(az boards work-item create --title "Add Build Service to Project Contributors" --type 'Task' --query "id" -o tsv)
echo $TASKID
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID
# 4b. Add the Build Service to other roles
TASKID=$(az boards work-item create --title "Give build service repo perms: Bypass PR, Force Push" --type 'Task' --query "id" -o tsv)
echo $TASKID
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID
# 5. Set pipeline folder required reviewer
TASKID=$(az boards work-item create --title "Change azure-pipelines required reviewer to security group" --type 'Task' --query "id" -o tsv)
echo $TASKID
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID
# 6. Set pipeline folder required reviewer
TASKID=$(az boards work-item create --title "Review number of approvers, and other repo build policies" --type 'Task' --query "id" -o tsv)
echo $TASKID
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID
# 7. Set pipeline folder required reviewer
TASKID=$(az boards work-item create --title "Allow the pipelines access to the variable groups" --type 'Task' --query "id" -o tsv)
echo $TASKID
az boards work-item relation add --id $TASKID --relation-type 'parent' --target-id $USERSTORYID

sleep 30s
az boards work-item show --id $USERSTORYID --open
