LOC="westeurope"

PREFIX="g"
SUFFIX=$(date -d "$D" '+%d%m')#

MONSUBID=""
MONRG=""
MONNAME=""

VERSION=$(az aks get-versions -l $LOC --query 'orchestrators[-1].orchestratorVersion' -o tsv)

az aks create \
    --resource-group K8s \ 
    --location $LOC \
    --name ${PREFIX}aks${SUFFIX} \
    --vm-set-type VirtualMachineScaleSets \
    --node-count 1 \
    --enable-vmss \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 3 \
    --attach-acr gordopremiumreg \
    --load-balancer-sku standard \
    --generate-ssh-keys \
    --node-vm-size=Standard_B2s \
    --kubernetes-version $VERSION \
    --generate-ssh-keys \
    --enable-addons monitoring \
    --workspace-resource-id "/subscriptions/${MONSUBID}/resourcegroups/${MONRG}/providers/microsoft.operationalinsights/workspaces/${MONNAME}"
