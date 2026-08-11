resource "azurerm_resource_group" "project_ascend" {
  name     = var.resource_group_name
  location = var.location
}