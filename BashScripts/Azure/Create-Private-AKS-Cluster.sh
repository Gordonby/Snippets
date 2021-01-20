echo "Checking for updates for the AKS preview extension"
az extension update -n aks-preview

echo "Displaying current subscription context"
az account show -o table

LOC="westeurope"

PREFIX="priv"
SUFFIX=$(date -d "$D" '+%d%m')

USERNAME_WIN=""
PASSWORD_WIN="P@ssw0rd1234"

MONRG="oms"
MONNAME="gobyers"

ACRNAME="gordopremiumreg"

VERSION=$(az aks get-versions -l $LOC --query 'orchestrators[-1].orchestratorVersion' -o tsv)

echo "Checking Variables..."
echo "Suffix is $SUFFIX"
echo "Version is $VERSION"

echo "Checking Azure dependant resources exist..."
echo "  Checking Azure Container Registry..."
az acr show -n $ACRNAME -o table

echo "  Checking Monitoring Insights exists..."
az resource show -g $MONRG -n $MONNAME --resource-type Microsoft.OperationalInsights/workspaces -o table

echo "  Monitoring Insights Resouce Id"
MONID=$(az resource show -g $MONRG -n $MONNAME --resource-type Microsoft.OperationalInsights/workspaces -o json --query 'id' -o tsv)
echo $MONID

read -p "Still want to create the cluster? [use ctrl+c to cancel] " ANSWER

echo "Creating the cluster"
az aks create -n ${PREFIX}aks${SUFFIX} \
    -g K8s --location $LOC \
    --load-balancer-sku standard \
    --enable-private-cluster \
    --network-plugin azure \
    --vnet-subnet-id "/subscriptions/2d5bb2c8-8be8-4539-b48f-fbfd86852fa9/resourceGroups/ContosoDomain/providers/Microsoft.Network/virtualNetworks/ContosoDomain-vnet/subnets/Aks" \
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.2.0.10 \
    --service-cidr 10.2.0.0/24
