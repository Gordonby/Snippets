az group create --name $1 --location eastus --tag Environment=Prod
az role assignment create --role Contributor --resource-group $1 --assignee 9cebaf93-813d-489e-b027-6532a125012c
az aks create --resource-group $1 --name $1Cluster --node-count 1 --generate-ssh-keys --kubernetes-version 1.9.6 --node-vm-size=Standard_B2s
az aks get-credentials --resource-group $1 --name $1Cluster
