# APIM arm templates

## Internal Mode with PIP - process

This is the steps that i've taken to stand up a new APIM instance in bicep code. Verbosity is deliberate.

- Start with identifying a good base template, from [Quick start Templates](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.apimanagement/api-management-create-with-internal-vnet-publicip/azuredeploy.json)
- Decompiled to bicep (15 warnings about bool->string property conversion)
- Fixed the warnings (bool->string property conversion)
- Removed vnet/subnet creation, instead expecting an existing vnet/subnet (added a new Vnet RGName parameter to facilitate)
- Changed SKU (developer) and Instance size (1) parameter defaults for cost optimisation
- Changed other parameter values for specific deployment
- Added condition for developer sku, to skip using availability zones
- Split out Networking to module, to cope with existing Virtual Network likely being in a different Resource Group
- Added parameter to make PublicIp creation optional
- Added NameSeed parameter and changed naming of Azure resources to converge on CAF recommendations
- Test deployment (1 hour 15mins to West Europe)
- Test deployment again (1 hour 11mins to West Europe) for timing consistency check (1 hour 15mins to West Europe)
- Grab [APIM Kv sample](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.apimanagement/api-management-key-vault-create/azuredeploy.json) and decompile to bicep, for easy copy & pasting
- Create a [KV](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.apimanagement/api-management-key-vault-create/azuredeploy.json#L110)
- Use a [UAI](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.apimanagement/api-management-key-vault-create/azuredeploy.json#L140)
- Add [Hostname config](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.apimanagement/api-management-key-vault-create/azuredeploy.json#L151)
- Prefixed the module deployment name with the parent deployment name (avoids conflicts)
- Test updating existing deployment with KeyVault and hostname config (25 minutes)
- Test new, full deployment (1 hour 14mins to West Europe)

### TODO

- Test contacting the built-in API in APIM
- Add optional log analytics workspace creation
- Add developer portal (and other) custom hostname

## Instructions

### Prerequisites

#### DNS names

You need to decide on the DNS custom domain that will be used to access the various API Management endpoints.
Azure External and Private DNS can both be leveraged, configuration thereof is outside the scope of the template.

#### SSL certificate string

Get a SSL Certificate for your domain

```bash
sudo apt install certbot
sudo certbot certonly --manual --preferred-challenges dns
```

Convert and capture the pfx string, and use in the Parameters to be loaded into KeyVault

```bash
domain="private.azdemo.co.uk"
sudo openssl pkcs12 -inkey /etc/letsencrypt/live/$domain/privkey.pem -in /etc/letsencrypt/live/$domain/cert.pem -export -out /etc/letsencrypt/live/$domain/pkcs12.pfx -passout pass:
GW=$(cat /etc/letsencrypt/live/$domain/pkcs12.pfx | base64 | tr -d '\n')
$GW>apimgwkey.txt
```

### Prep your parameter defaults (or parameter file)

All parameter values should be reviewed and tweaked for your environment. Your DNS name and SSL certificate are the ones that need a little more planning.

### Running the bicep file

Test with a what-if, to see what resources will be created.

```bash
$RG= 'ApimTest1'
$NameSeed= 'ApimAtt1'

az deployment group what-if -n innerloop1 -f .\apim-internalvnet-publicip.bicep -g $RG -p nameSeed=$NameSeed
```

Deploy the template

```bash
az deployment group create -n innerloop1 -f .\apim-internalvnet-publicip.bicep -g $RG -p nameSeed=$NameSeed
```
