locals {
  project          = "aidp"
  phase            = "phase7"
  env              = "lab"
  region           = "eu-west-1"
  eks_cluster_name = "aidp-phase7-eks"
  node_group_name  = "aidp-phase7-ng"

  common_tags = {
    project = local.project
    phase   = local.phase
    env     = local.env
    owner   = "selcuk"
    stack   = "eks"
  }
}