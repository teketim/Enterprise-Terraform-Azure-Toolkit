output "hub_vnet_id" {
  description = "Resource ID of the hub virtual network."
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Name of the hub virtual network."
  value       = azurerm_virtual_network.hub.name
}

output "hub_subnet_ids" {
  description = "Map of hub subnet names to resource IDs."

  value = {
    for name, subnet in azurerm_subnet.hub :
    name => subnet.id
  }
}
output "dr_vnet_id" {
  description = "Resource ID of the DR spoke virtual network."
  value       = azurerm_virtual_network.dr_spoke.id
}

output "dr_vnet_name" {
  description = "Name of the DR spoke virtual network."
  value       = azurerm_virtual_network.dr_spoke.name
}

output "dr_subnet_ids" {
  description = "Map of DR spoke subnet names to resource IDs."

  value = {
    for name, subnet in azurerm_subnet.dr_spoke :
    name => subnet.id
  }
}

output "hub_to_dr_peering_id" {
  description = "Resource ID of the Hub-to-DR VNet peering."
  value       = azurerm_virtual_network_peering.hub_to_dr.id
}

output "dr_to_hub_peering_id" {
  description = "Resource ID of the DR-to-Hub VNet peering."
  value       = azurerm_virtual_network_peering.dr_to_hub.id
}