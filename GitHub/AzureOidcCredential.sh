# This script provides a simple way to update an Application with a GitHub-usable OIDC federated credential.
# Based on the steps outlined here: https://docs.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Clinux

#Set up user specific variables
EXISTS=false
APPNAME=AksBaselineFedCred
RG=AksBicepAcc-Ci-BasicCluster
GHORG=Azure
GHREPO=aks-baseline-automation
GHBRANCH=gb-docs
GHENV=gord

if [ $EXISTS == true ]; then
    echo "Getting existing APP $APPNAME"

    appId=$(az ad app list --display-name $APPNAME --query "[].appId" -o tsv)
    SP=$(az ad sp show --id $appId)
else
    echo "Creating new APP $APPNAME"

    APP=$(az ad app create --display-name $APPNAME)
    appId=$(echo $APP | jq -r ".appId"); echo $appId
    SP=$(az ad sp create --id $appId)
fi
assigneeObjectId=$(echo $SP | jq -r ".objectId"); echo $assigneeObjectId

#Create Role Assignment (Azure RG RBAC)
az role assignment create --role contributor --resource-group $RG  --assignee-object-id  $assigneeObjectId --assignee-principal-type ServicePrincipal
az role assignment create --role "Azure Kubernetes Service RBAC Cluster Admin" --resource-group $RG  --assignee-object-id  $assigneeObjectId --assignee-principal-type ServicePrincipal

#Create federated identity credentials for use from a GitHub Branch
fedReqUrl="https://graph.microsoft.com/beta/applications/$applicationObjectId/federatedIdentityCredentials"
fedReqBody=$(jq -n --arg n "$APPNAME-branch-$GHBRANCH" \
                   --arg r "repo:$GHORG/$GHREPO:ref:refs/heads/$GHBRANCH" \
                   --arg d "Access for GitHub branch $GHBRANCH" \
             '{name:$n,issuer:"https://token.actions.githubusercontent.com",subject:$r,description:$d,audiences:["api://AzureADTokenExchange"]}')
echo $fedReqBody | jq -r
az rest --method POST --uri $fedReqUrl --body "$fedReqBody"

#Create federated identity credentials for use from a GitHub Environment
fedReqUrl="https://graph.microsoft.com/beta/applications/$applicationObjectId/federatedIdentityCredentials"
fedReqBody=$(jq -n --arg n "$APPNAME-env-$GHENV" \
                   --arg r "repo:$GHORG/$GHREPO:environment:$GHENV" \
                   --arg d "Access for GitHub environment $GHENV" \
             '{name:$n,issuer:"https://token.actions.githubusercontent.com",subject:$r,description:$d,audiences:["api://AzureADTokenExchange"]}')
echo $fedReqBody | jq -r
az rest --method POST --uri $fedReqUrl --body "$fedReqBody"

#Retrieving values needed for GitHub secret creation
subscriptionId=$(az account show --query id -o tsv)
applicationObjectId=$(echo $APP | jq -r ".objectId")
clientId=$appId
tenantId=$(az account show --query tenantId -o tsv)

echo "Create these GitHub secrets"
echo -e "AZURE_CLIENT_ID: $clientId\nAZURE_TENANT_ID: $tenantId\nAZURE_SUBSCRIPTION_ID: $subscriptionId"