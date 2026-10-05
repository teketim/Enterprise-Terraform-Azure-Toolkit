output "id" {
  description = "Resource ID of the Azure resource group."
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "Name of the Azure resource group."
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Azure region associated with the resource group."
  value       = azurerm_resource_group.this.location
}
