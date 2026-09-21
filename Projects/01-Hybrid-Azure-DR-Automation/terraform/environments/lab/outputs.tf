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
