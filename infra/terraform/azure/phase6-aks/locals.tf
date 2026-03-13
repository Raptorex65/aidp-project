locals {
  project             = "aidp"
  phase               = "phase6"
  env                 = "lab"
  region              = "ne"
  resource_group_name = "aidp-phase6-aks-rg"
  vnet_name           = "aidp-phase6-vnet"
  subnet_name         = "aks-subnet"
  aks_cluster_name    = "aidp-phase6-aks"

  common_tags = {
    project = "local.project"
    phase   = "local.phase"
    env     = "local.env"
    owner   = "selcuk"
    stack   = "aks"
  }
}