#main.tf

data "http" "aksc_release" {
  url = "https://github.com/Azure/AKS-Construction/releases/download/0.7.0/main.json"
  request_headers = {
    Accept = "application/json"
    User-Agent = "request module"
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name = "az-k8s-d14j-rg"
  location = "WestEurope"
}

resource "azurerm_resource_group_template_deployment" "aksc_deploy" {
  name = "AKS-C"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode = "Incremental"
  template_content = data.http.aksc_release.body
  parameters_content = jsonencode({
    resourceName = {value=var.resourceName}
    upgradeChannel = {value=var.upgradeChannel}
    custom_vnet = {value=var.custom_vnet}
    enable_aad = {value=var.enable_aad}
    AksDisableLocalAccounts = {value=var.AksDisableLocalAccounts}
    enableAzureRBAC = {value=var.enableAzureRBAC}
    registries_sku = {value=var.registries_sku}
    acrPushRolePrincipalId = {value=data.azurerm_client_config.current.client_id}
    omsagent = {value=var.omsagent}
    retentionInDays = {value=var.retentionInDays}
    networkPolicy = {value=var.networkPolicy}
    azurepolicy = {value=var.azurepolicy}
    authorizedIPRanges = {value=var.authorizedIPRanges}
    ingressApplicationGateway = {value=var.ingressApplicationGateway}
    appGWcount = {value=var.appGWcount}
    appGWsku = {value=var.appGWsku}
    appGWmaxCount = {value=var.appGWmaxCount}
    appgwKVIntegration = {value=var.appgwKVIntegration}
    azureKeyvaultSecretsProvider = {value=var.azureKeyvaultSecretsProvider}
    createKV = {value=var.createKV}
    kvOfficerRolePrincipalId = {value=data.azurerm_client_config.current.client_id}
  })
}