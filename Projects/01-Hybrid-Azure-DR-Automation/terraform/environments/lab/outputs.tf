output "resource_group_id" {
  description = "Resource ID of the DR lab resource group."
  value       = module.resource_group.id
}

output "resource_group_name" {
  description = "Name of the DR lab resource group."
  value       = module.resource_group.name
}

output "resource_group_location" {
  description = "Azure region of the DR lab resource group."
  value       = module.resource_group.location
}
output "hub_vnet_id" {
  description = "Resource ID of the hub virtual network."
  value       = module.networking.hub_vnet_id
}

output "hub_vnet_name" {
  description = "Name of the hub virtual network."
  value       = module.networking.hub_vnet_name
}

output "hub_subnet_ids" {
  description = "Map of hub subnet names to resource IDs."
  value       = module.networking.hub_subnet_ids
}