#download the *.tf files and run these commands to deploy using terraform
#for more AKS Construction samples of deploying with terraform, see https://aka.ms/aksc/terraform

terraform fmt
terraform init
terraform validate
terraform plan -out main.tfplan
terraform apply main.tfplan
terraform output