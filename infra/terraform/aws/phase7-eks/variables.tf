variable "cluster_version" {
  description = "EKS kub8s version"
  type        = string
  default     = "1.29"
}

variable "node_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "node_min_size" {
  type    = number
  default = 1
}