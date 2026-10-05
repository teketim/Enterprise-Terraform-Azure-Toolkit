# ============================================
# Project Ascend - Lab 02
# Variable Definitions
# ============================================

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Azure virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space assigned to the virtual network"
  type        = list(string)
}

# ============================================
# Subnet Configuration
# ============================================

variable "subnets" {
  description = "Map of subnet names to CIDR address prefixes"
  type        = map(string)
}