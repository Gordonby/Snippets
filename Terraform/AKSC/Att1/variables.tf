#variables.tf
 
variable resourceName {
  default="az-k8s-jvc6"
} 
variable JustUseSystemPool {
  default=true
} 
variable agentCountMax {
  default=0
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
