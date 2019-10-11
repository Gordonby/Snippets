
LOC=westeurope
RGNAME=GHES
VMNAME=GHES-Amsterdam
MYSOURCEIPRANGE=86.176.175.178

#Check latest images with this
#az vm image list -f GitHub-Enterprise -l $LOC -p GitHub --all

az vm create -n $VMNAME -g $RGNAME --size Standard_DS11_v2 -l $LOC --image GitHub:GitHub-Enterprise:GitHub-Enterprise:2.18.4 --storage-sku Premium_LRS

az network nsg show -n ${VMNAME}NSG -g $RGNAME

az network nsg rule create -g $RGNAME --nsg-name ${VMNAME}NSG -n GitSSH --priority 500 \
    --source-address-prefixes $MYSOURCEIPRANGE --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 22 --access Allow \
    --protocol Tcp --description "Git over SSH access."
az network nsg rule create -g $RGNAME --nsg-name ${VMNAME}NSG -n SMTP --priority 510 \
    --source-address-prefixes $MYSOURCEIPRANGE --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 25 --access Allow \
    --protocol Tcp --description "SMTP with encryption (STARTTLS) support."
az network nsg rule create -g $RGNAME --nsg-name ${VMNAME}NSG -n HTTP --priority 520 \
    --source-address-prefixes $MYSOURCEIPRANGE --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 80 --access Allow \
    --protocol Tcp --description "Web application access"
az network nsg rule create -g $RGNAME --nsg-name ${VMNAME}NSG -n Shell --priority 530 \
    --source-address-prefixes $MYSOURCEIPRANGE --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 122 --access Allow \
    --protocol Tcp --description "Instance shell access"
az network nsg rule create -g $RGNAME --nsg-name ${VMNAME}NSG -n HTTP --priority 540 \
    --source-address-prefixes $MYSOURCEIPRANGE --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 161 --access Allow \
    --protocol Udp --description "Network monitoring"
az network nsg rule create -g $RGNAME --nsg-name ${VMNAME}NSG -n HTTPS --priority 550 \
    --source-address-prefixes $MYSOURCEIPRANGE --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 443 --access Allow \
    --protocol Tcp --description "Web application and Git over HTTPS access"
az network nsg rule create -g $RGNAME --nsg-name ${VMNAME}NSG -n HAREPL --priority 560 \
    --source-address-prefixes $MYSOURCEIPRANGE --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 1194 --access Allow \
    --protocol Udp --description "Secure replication network tunnel in high availability configuration"
az network nsg rule create -g $RGNAME --nsg-name ${VMNAME}NSG -n MConsole --priority 570 \
    --source-address-prefixes $MYSOURCEIPRANGE --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 8080 --access Allow \
    --protocol Tcp --description "Plain-text web based Management Console"
az network nsg rule create -g $RGNAME --nsg-name ${VMNAME}NSG -n SecHTTPS --priority 580 \
    --source-address-prefixes $MYSOURCEIPRANGE --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 8443 --access Allow \
    --protocol Tcp --description "Secure web based Management Console."
az network nsg rule create -g $RGNAME --nsg-name ${VMNAME}NSG -n SimpleGit --priority 590 \
    --source-address-prefixes $MYSOURCEIPRANGE --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges 9418 --access Allow \
    --protocol Tcp --description "Simple Git protocol port."
az network nsg rule create -g $RGNAME --nsg-name ${VMNAME}NSG -n DenyAll --priority 900 \
    --source-address-prefixes '*' --source-port-ranges '*' \
    --destination-address-prefixes '*' --destination-port-ranges '*' --access Deny\
    --description "Deny all"

#My "Non-prod" data disk, see size and caching setting.
#az vm disk attach --vm-name $VMNAME -g $RGNAME --sku Premium_LRS --new -z 512 --disk ghe-data.vhd
az vm disk attach --vm-name $VMNAME -g $RGNAME --sku Premium_LRS --new -z 64 --name ghe-data.vhd --caching ReadWrite

az network public-ip update -g $RGNAME -n ${VMNAME}PublicIP --dns-name gordonsgithubes
