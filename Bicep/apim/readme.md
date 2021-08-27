# APIM arm templates

## Internal Mode with PIP

This is the steps that i've taken to stand up a new APIM instance in bicep code. Verbosity is deliberate.

- Taken from [Quick start Templates](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.apimanagement/api-management-create-with-internal-vnet-publicip/azuredeploy.json)
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


### to-do
- Use letsencrpt to generate a wildcard ssl cert for the parameter
- Test kv deployment
- Update this readme with instructions on hostname/ssl and pwsh for the letsencrypt
- Add optional log analytics workspace creation
