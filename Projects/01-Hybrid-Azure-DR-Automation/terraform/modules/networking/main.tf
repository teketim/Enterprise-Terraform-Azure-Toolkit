resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.hub_address_space

  tags = var.tags
}

resource "azurerm_subnet" "hub" {
  for_each = var.hub_subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [each.value]
}
resource "azurerm_virtual_network" "dr_spoke" {
  name                = var.dr_vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.dr_address_space

  tags = var.tags
}

resource "azurerm_subnet" "dr_spoke" {
  for_each = var.dr_subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.dr_spoke.name
  address_prefixes     = [each.value]
}

resource "azurerm_virtual_network_peering" "hub_to_dr" {
  name                      = "peer-hub-to-dr"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.dr_spoke.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "dr_to_hub" {
  name                      = "peer-dr-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.dr_spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}