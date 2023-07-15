#For creating a minecraft server that runs on an ACI Instance

SUB="PseudoProd"
RG="MinecraftBedrock"
LOC="uksouth"
STOR="minecraftdataby"
SHARE="minecraftdata"
CONT="aci-minecraftby"
WORLD="byers-ultimate-world"
ACRNAME="gbpseudoprod"

az account set -s $SUB

KEY=$(az storage account keys list -n $STOR -g $RG -o tsv --query '[0].value')

az container create \
    --resource-group $RG \
    --name $CONT \
    --image itzg/minecraft-bedrock-server:latest \
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
        'DEBUG'='TRUE' \
        'GAMEMODE'='survival' \
        'LEVEL_NAME'=$WORLD \
        'LEVEL_SEED'='8486214866965744170' \
        'TICK_DISTANCE'='4'

FQDN=$(az container show -n $CONT -g $RG --query ipAddress.fqdn -o tsv)
echo $FQDN

az container logs -g $RG -n $CONT --follow
