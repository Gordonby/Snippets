echo "Checking for updates for the AKS preview extension"
az extension update -n aks-preview

echo "Displaying current subscription context"
az account show -o table

LOC="eastus"

PREFIX="g5"
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
    --vm-set-type VirtualMachineScaleSets \
    --node-count 1 \
    --enable-vmss \
    --enable-cluster-autoscaler \
    --min-count 1 --max-count 4 \
    --load-balancer-sku standard \
    --generate-ssh-keys \
    --node-vm-size=Standard_B2s \
    --kubernetes-version $VERSION \
    --windows-admin-password $PASSWORD_WIN \
    --windows-admin-username $USERNAME_WIN \
    --network-plugin azure \
    --enable-addons monitoring \
    --workspace-resource-id $MONID \
    --verbose

echo "Adding the ACR role"
  az aks update -n ${PREFIX}aks${SUFFIX} -g K8s --attach-acr $ACRNAME

echo "Adding windows nodepool"
  az aks nodepool add \
    --resource-group K8s \
    --cluster-name ${PREFIX}aks${SUFFIX} \
    --name winpoo \
    --node-count 1 \
    --kubernetes-version  $VERSION \
    --os-type Windows \
    --node-vm-size=Standard_B2s \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 2 \
    --node-taints key=value:NoSchedule

echo "Getting kube context"
  az aks get-credentials -g K8s -n ${PREFIX}aks${SUFFIX}

echo "Adding clusterrolebinding for dashboard"
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
