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