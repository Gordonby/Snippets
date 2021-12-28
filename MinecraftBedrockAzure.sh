SUB="PseudoProd"
RG="MinecraftBedrock"
LOC="uksouth"
STOR="minecaftbedrock555"
SHARE="minecraftmodworlddata"
CONT="minecraftmodbedrockaci"
WORLD="byers-mod-world"

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

az container create \
    --resource-group $RG \
    --name $CONT \
    --image itzg/minecraft-bedrock-server:latest \
    --dns-name-label $WORLD \
    --ports 19132 \
    --protocol UDP \
    --azure-file-volume-account-name $STOR \
    --azure-file-volume-account-key $KEY \
    --azure-file-volume-share-name $SHARE \
    --azure-file-volume-mount-path /data \
    --environment-variables \
        'EULA'='TRUE' \
        'GAMEMODE'='creative' \
        'ALLOW_CHEATS'='true' \
        'LEVEL_NAME'='byers modworld' \
        'LEVEL_SEED'='-78688046' \
        'DIFFICULTY'='easy'

FQDN=$(az container show -n $CONT -g $RG --query ipAddress.fqdn -o tsv)

echo $FQDN
