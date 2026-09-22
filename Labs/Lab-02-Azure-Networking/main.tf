# ============================================
# Project Ascend - Lab 02
# Azure Networking Resources
# ============================================

resource "azurerm_virtual_network" "project_ascend" {

  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}
# ============================================
# Project Ascend Subnets
# ============================================

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.project_ascend.name

  address_prefixes = [
    each.value
  ]
}

