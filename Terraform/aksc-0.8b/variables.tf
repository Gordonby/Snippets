#variables.tf

variable resourceGroupName {
  default="az-k8s-jnpw-rg"
} 
variable resourceName {
  default="az-k8s-jnpw"
} 
variable upgradeChannel {
  default="stable"
} 
variable custom_vnet {
  default=true
} 
variable enable_aad {
  default=true
} 
variable AksDisableLocalAccounts {
  default=true
} 
variable enableAzureRBAC {
  default=true
} 
variable registries_sku {
  default="Premium"
} 
variable omsagent {
  default=true
} 
variable retentionInDays {
  default=30
} 
variable networkPolicy {
  default="azure"
} 
variable azurepolicy {
  default="audit"
} 
variable authorizedIPRanges {
  default=["86.144.109.46/32"]
} 
variable ingressApplicationGateway {
  default=true
} 
variable appGWcount {
  default=0
} 
variable appGWsku {
  default="WAF_v2"
} 
variable appGWmaxCount {
  default=10
} 
variable appgwKVIntegration {
  default=true
} 
variable azureKeyvaultSecretsProvider {
  default=true
} 
variable createKV {
  default=true
}