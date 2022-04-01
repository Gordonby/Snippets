data "http" "aksc_release" {
  url = "https://github.com/Azure/AKS-Construction/releases/download/0.6.2/main.json"
  request_headers = {
    Accept = "application/json"
  }
}

data "azurerm_client_config" "azcontext" {}

resource "azurerm_resource_group" "rg" {
  name = "az-k8s-eiwl-rg"
  location = "WestEurope"
}

resource "azurerm_resource_group_template_deployment" "aksc_deploy" {
  name = "AKS-C"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode = "Incremental"
  template_content = data.http.aksc_release.body
  parameters_content = jsonencode({
    location = azurerm_resource_group.rg.location
    resourceName = var.resourceName
    JustUseSystemPool = var.JustUseSystemPool
    agentCountMax = var.agentCountMax
  })
}
