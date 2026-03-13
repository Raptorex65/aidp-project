variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "northeurope"
}

variable "vnet_address_space" {
  description = "VNet CIDR"
  type        = list(string)
  default     = ["10.60.0.0/16"]
}

variable "aks_subnet_prefixes" {
  description = "AKS subnet CIDR"
  type        = list(string)
  default     = ["10.60.1.0/24"]
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version"
  type        = string
  default     = null
}

variable "system_node_vm_size" {
  description = "VM size for system pool"
  type        = string
  default     = "Standard_B2s"
}

variable "system_node_count" {
  description = "Initial system node count"
  type        = number
  default     = 1
}

variable "user_node_vm_size" {
  description = "VM size for user pool"
  type        = string
  default     = "Standard_B2s"
}

variable "user_node_count" {
  description = "Initial user node count"
  type        = number
  default     = 1
}