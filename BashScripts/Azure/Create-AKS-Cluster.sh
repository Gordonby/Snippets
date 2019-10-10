LOC="eastus"

PREFIX=""
SUFFIX=$(date -d "$D" '+%d%m')

USERNAME_WIN=""
PASSWORD_WIN="P@ssw0rd1234"

MONSUBID=""
MONRG=""
MONNAME=""

ACRNAME="gordopremiumreg"

VERSION=$(az aks get-versions -l $LOC --query 'orchestrators[-1].orchestratorVersion' -o tsv)

az aks create -n ${PREFIX}aks${SUFFIX} \
    -g K8s --location $LOC \
    --vm-set-type VirtualMachineScaleSets \
    --node-count 1 \
    --enable-vmss \
    --enable-cluster-autoscaler \
    --min-count 1 --max-count 2 \
    --attach-acr $ACRNAME \
    --load-balancer-sku standard \
    --generate-ssh-keys \
    --node-vm-size=Standard_B2s \
    --kubernetes-version $VERSION \
    --generate-ssh-keys \
    --windows-admin-password $PASSWORD_WIN \
    --windows-admin-username $USERNAME_WIN \
    --network-plugin azure \
    --enable-addons monitoring \
    --workspace-resource-id "/subscriptions/${MONSUBID}/resourcegroups/${MONRG}/providers/microsoft.operationalinsights/workspaces/${MONNAME}"

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
    --max-count 2
