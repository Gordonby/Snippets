#variables.tf

variable "resourceGroupName" {
  type    = string
  default = "az-k8s-i2lh-rg"
}
variable "location" {
  type    = string
  default = "WestEurope"
}
variable "resourceName" {
  type    = string
  default = "az-k8s-i2lh"
}
variable "upgradeChannel" {
  type    = string
  default = "stable"
}
variable "custom_vnet" {
  type    = bool
  default = true
}
variable "enable_aad" {
  type    = bool
  default = true
}
variable "AksDisableLocalAccounts" {
  type    = bool
  default = true
}
variable "enableAzureRBAC" {
  type    = bool
  default = true
}
variable "registries_sku" {
  type    = string
  default = "Premium"
}
variable "omsagent" {
  type    = bool
  default = true
}
variable "retentionInDays" {
  type    = number
  default = 30
}
variable "networkPolicy" {
  type    = string
  default = "azure"
}
variable "azurepolicy" {
  type    = string
  default = "audit"
}
variable "authorizedIPRanges" {
  default = ["86.144.109.46/32"]
}
variable "ingressApplicationGateway" {
  type    = bool
  default = true
}
variable "appGWcount" {
  type    = number
  default = 0
}
variable "appGWsku" {
  type    = string
  default = "WAF_v2"
}
variable "appGWmaxCount" {
  type    = number
  default = 10
}
variable "appgwKVIntegration" {
  type    = bool
  default = true
}
variable "azureKeyvaultSecretsProvider" {
  type    = bool
  default = true
}
variable "createKV" {
  type    = bool
  default = true
}