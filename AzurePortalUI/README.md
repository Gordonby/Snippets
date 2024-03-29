
##  Portal Form UI

Open the [Form View Sandbox](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/FormSandboxBlade),select `CustomTemplate` as the package type and then provide your ARM json file to be parsed and a Portal UI form spec created. [Docs](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/template-specs-create-portal-forms#create-default-form)

## App Service 
[This Page](https://github.com/Azure/appservice-landing-zone-accelerator/blob/main/scenarios/secure-baseline-multitenant/README.md) facilitates deployment of the Landing Zone using a custom UI;
https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fappservice-landing-zone-accelerator%2Fmain%2Fscenarios%2Fsecure-baseline-multitenant%2Fazure-resource-manager%2Fmain.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fappservice-landing-zone-accelerator%2Fmain%2Fscenarios%2Fsecure-baseline-multitenant%2Fazure-resource-manager%2Fmain-portal-ux.json


The URL provides a `uiFormDefinitionUri`;
```
https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/
https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fappservice-landing-zone-accelerator%2Fmain%2Fscenarios%2Fsecure-baseline-multitenant%2Fazure-resource-manager%2Fmain.json
/uiFormDefinitionUri/
https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fappservice-landing-zone-accelerator%2Fmain%2Fscenarios%2Fsecure-baseline-multitenant%2Fazure-resource-manager%2Fmain-portal-ux.json
```

This is compresived of the [compiled arm template](https://github.com/Azure/appservice-landing-zone-accelerator/blob/main/scenarios/secure-baseline-multitenant/azure-resource-manager/main.json) and a [UX Scaffold json file](https://github.com/Azure/appservice-landing-zone-accelerator/blob/main/scenarios/secure-baseline-multitenant/azure-resource-manager/main-portal-ux.json).

[app-service-main-portal-ux.json](app-service-main-portal-ux.json)

## AKS Construction

https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FGordonby%2FSnippets%2Fmaster%2FAzurePortalUI%2Faksc0915.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FGordonby%2FSnippets%2Fmaster%2FAzurePortalUI%2FportalUI-0915-cool-v3.json
