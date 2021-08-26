# APIM arm templates

## Internal Mode with PIP

- Taken from [Quick start Templates](https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.apimanagement/api-management-create-with-internal-vnet-publicip/azuredeploy.json)
- Decompiled to bicep (15 warnings about bool->string property conversion)
- Fixed the warnings (bool->string property conversion)
- Removed vnet/subnet creation, instead expecting an existing vnet/subnet (added a new Vnet RGName parameter to facilitate)
- Changed SKU and Instance size parameter defaults for cost optimisation
- Changed other parameter values for specific deployment
- Added condition for developer sku, to skip using availability zones
- Split out Networking to module, to cope with existing Virtual Network likely being in a different Resource Group
- Added parameter to make PublicIp creation optional
- Changed naming of Azure resources to converge on CAF recommendations
