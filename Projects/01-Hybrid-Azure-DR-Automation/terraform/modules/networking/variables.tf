variable "resource_group_name" {
  description = "Name of the resource group containing the network resources"
  type        = string
}

variable "location" {
  description = "Azure region for the network resources"
  type        = string
}

variable "hub_vnet_name" {
  description = "Name of the hub virtual network"
  type        = string
}

variable "hub_address_space" {
  description = "Address space assigned to the hub virtual network"
  type        = list(string)
}

variable "hub_subnets" {
  description = "Map of hub subnet names and address prefixes"
  type        = map(string)
}

variable "tags" {
  description = "Common tags applied to supported resources"
  type        = map(string)
  default     = {}
}