resource "azurerm_resource_group" "aks_rg" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = local.vnet_name
  location            = var.location
  resource_group_name = local.resource_group_name
  address_space       = var.vnet_address_space
  tags                = local.common_tags
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = local.subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = var.aks_subnet_prefixes
  depends_on = [ azurerm_virtual_network.aks_vnet ]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.aks_cluster_name
  location            = var.location
  resource_group_name = local.resource_group_name
  dns_prefix          = "${local.aks_cluster_name}-dns"

  kubernetes_version = var.kubernetes_version

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                         = "sysnp"
    vm_size                      = var.system_node_vm_size
    node_count                   = var.system_node_count
    vnet_subnet_id               = azurerm_subnet.aks_subnet.id
    os_disk_size_gb              = 30
    auto_scaling_enabled         = false
    type                         = "VirtualMachineScaleSets"
    temporary_name_for_rotation  = "sysrotate"
    only_critical_addons_enabled = true

    tags = {
      pool = "system"
    }
  }
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  role_based_access_control_enabled = true
  tags                              = local.common_tags
}

resource "azurerm_kubernetes_cluster_node_pool" "user_pool" {
  name                  = "usernp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.user_node_vm_size
  node_count            = var.user_node_count
  vnet_subnet_id        = azurerm_subnet.aks_subnet.id
  os_disk_size_gb       = 30
  mode                  = "User"
  auto_scaling_enabled  = false

  node_labels = {
    workload = "apps"
  }

  tags = {
    pool = "user"
  }
}