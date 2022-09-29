#For creating a minecraft server that runs on an ACI Instance

SUB="PseudoProd"
RG="MinecraftBedrock"
LOC="uksouth"
STOR="minecaftbedrock555"
SHARE="bworldu"
CONT="bworldu"
WORLD="byers-ultimate-world"
VERSION="1.19.30.04"
ACRNAME="gbpseudoprod"

az account set -s $SUB

az group create --name $RG --location $LOC

az storage account create \
    --resource-group $RG \
    --name $STOR \
    --kind StorageV2 \
    --sku Standard_ZRS \
    --enable-large-file-share \
    --output none

KEY=$(az storage account keys list -g $RG -n $STOR --query [0].value -o tsv)

az storage share create \
    --account-name $STOR \
    --name $SHARE \
    --account-key $KEY \
    --quota 1024 \
    --output none

ACRPW=$(az acr credential show -n $ACRNAME --query "passwords[0].value" -o tsv)
ACRSERVER=$(az acr show -n $ACRNAME -g $RG --query loginServer -o tsv)
az acr import -n $ACRNAME --source docker.io/itzg/minecraft-bedrock-server:latest --image itzg/minecraft-bedrock-server:latest

az container create \
    --resource-group $RG \
    --name $CONT \
    --image $ACRSERVER/itzg/minecraft-bedrock-server:latest \
    --registry-username $ACRNAME \
    --registry-password $ACRPW \
    --cpu 2 --memory 2 \
    --dns-name-label $WORLD \
    --ports 19132 \
    --protocol UDP \
    --azure-file-volume-account-name $STOR \
    --azure-file-volume-account-key $KEY \
    --azure-file-volume-share-name $SHARE \
    --azure-file-volume-mount-path /data \
    --environment-variables \
        'EULA'='TRUE' \
        'VERSION'=$VERSION \
        'GAMEMODE'='survival' \
        'LEVEL_NAME'=$WORLD \
        'LEVEL_SEED'='8486214866965744170' \
        'DIFFICULTY'='easy'

FQDN=$(az container show -n $CONT -g $RG --query ipAddress.fqdn -o tsv)

echo $FQDN
