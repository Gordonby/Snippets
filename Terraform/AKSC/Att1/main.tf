#main.tf
data "http" "aksc_release" {
  url = "https://github.com/Azure/AKS-Construction/releases/download/0.6.2/main.json"
  request_headers = {
    Accept = "application/json"
    User-Agent = "request module"
  }
}

data "azurerm_client_config" "azcontext" {}

resource "azurerm_resource_group" "rg" {
  name = "az-k8s-jvc6-rg"
  location = "WestEurope"
}

resource "azurerm_resource_group_template_deployment" "aksc_deploy" {
  name = "AKS-C"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode = "Incremental"
  template_content = data.http.aksc_release.body
  parameters_content = jsonencode({
    resourceName = {value=var.resourceName}
    JustUseSystemPool = {value=var.JustUseSystemPool}
    agentCountMax = {value=var.agentCountMax}
    registries_sku = {value=var.registries_sku}
    #acrPushRolePrincipalId = {value=var.acrPushRolePrincipalId}
    omsagent = {value=var.omsagent}
    retentionInDays = {value=var.retentionInDays}
  })
}
