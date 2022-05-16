output aksClusterName {
  value = jsondecode(azurerm_resource_group_template_deployment.aksc_deploy.output_content).aksClusterName.value
}
